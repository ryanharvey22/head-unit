--  mailbox.adb — Pi 4: separate read/write mailbox status (not BCM2835 layout)
--
--  Bring-up: GPIO LED BCM 17 toggles slowly inside any spin-wait for VideoCore.
--  Entry: three flashes at start of Call (NOP spin delays, not Wait_Ms).

with Interfaces; use Interfaces;
with Hal.Clock;
with Hal.GPIO;
with System.Machine_Code;
with System.Storage_Elements; use System.Storage_Elements;

package body Mailbox is

   Debug_Pin : constant Hal.U32 := Hal.GPIO.Debug_LED_BCM;

   Spin_Hb_Every : constant := 5_000_000;

   Hb_Ctr : U32 := 0;
   Hb_Lvl : Boolean := False;

   procedure Reset_Hb is
   begin
      Hb_Ctr := 0;
   end Reset_Hb;

   procedure Spin_Hb is
   begin
      Hb_Ctr := Hb_Ctr + 1;
      if Hb_Ctr >= Spin_Hb_Every then
         Hb_Ctr := 0;
         Hb_Lvl := not Hb_Lvl;
         Hal.GPIO.Write (Debug_Pin, Hb_Lvl);
      end if;
   end Spin_Hb;

   procedure Pulse_Mbox_Enter is
      Flash_Iters : constant Natural := 12_000_000;
   begin
      for J in 1 .. 3 loop
         Hal.GPIO.Write (Debug_Pin, True);
         Hal.Clock.Busy_Wait_Loops (Flash_Iters);
         Hal.GPIO.Write (Debug_Pin, False);
         Hal.Clock.Busy_Wait_Loops (Flash_Iters);
      end loop;
   end Pulse_Mbox_Enter;

   MMIO_Base : constant := 16#FE000000#;
   Mbox_Base : constant := MMIO_Base + 16#B880#;

   Mbox_Read : U32;
   for Mbox_Read'Address use To_Address (Mbox_Base + 16#00#);
   pragma Volatile (Mbox_Read);
   pragma Import (Ada, Mbox_Read);

   Mbox0_Status : U32;
   for Mbox0_Status'Address use To_Address (Mbox_Base + 16#18#);
   pragma Volatile (Mbox0_Status);
   pragma Import (Ada, Mbox0_Status);

   Mbox_Write : U32;
   for Mbox_Write'Address use To_Address (Mbox_Base + 16#20#);
   pragma Volatile (Mbox_Write);
   pragma Import (Ada, Mbox_Write);

   Mbox1_Status : U32;
   for Mbox1_Status'Address use To_Address (Mbox_Base + 16#38#);
   pragma Volatile (Mbox1_Status);
   pragma Import (Ada, Mbox1_Status);

   Full_Bit  : constant U32 := 16#8000_0000#;
   Empty_Bit : constant U32 := 16#4000_0000#;
   Channel   : constant U32 := 8;

   GPU_Uncached_Base : constant U32 := 16#C000_0000#;

   Cache_Line : constant Integer_Address := 64;
   Buf_Bytes  : constant Integer_Address :=
      Integer_Address (Tag_Buffer'Size / System.Storage_Unit);

   procedure Dsb_Sy is
   begin
      System.Machine_Code.Asm ("dsb sy", Volatile => True, Clobber => "memory");
   end Dsb_Sy;

   procedure Dc_Cvac (Addr : System.Address) is
   begin
      System.Machine_Code.Asm (
         "dc cvac, %0",
         Inputs   => System.Address'Asm_Input ("r", Addr),
         Volatile => True,
         Clobber  => "memory");
   end Dc_Cvac;

   procedure Dc_Ivac (Addr : System.Address) is
   begin
      System.Machine_Code.Asm (
         "dc ivac, %0",
         Inputs   => System.Address'Asm_Input ("r", Addr),
         Volatile => True,
         Clobber  => "memory");
   end Dc_Ivac;

   procedure Sync_Buffer_To_Device is
      Base : constant Integer_Address := To_Integer (Buffer'Address);
      Last : constant Integer_Address := Base + Buf_Bytes;
      First_Line : constant Integer_Address :=
        (Base / Cache_Line) * Cache_Line;
      Last_Line : constant Integer_Address :=
        ((Last + Cache_Line - 1) / Cache_Line) * Cache_Line;
      Line : Integer_Address := First_Line;
   begin
      while Line < Last_Line loop
         Dc_Cvac (To_Address (Line));
         Line := Line + Cache_Line;
      end loop;
      Dsb_Sy;
   end Sync_Buffer_To_Device;

   procedure Sync_Buffer_From_Device is
      Base : constant Integer_Address := To_Integer (Buffer'Address);
      Last : constant Integer_Address := Base + Buf_Bytes;
      First_Line : constant Integer_Address :=
        (Base / Cache_Line) * Cache_Line;
      Last_Line : constant Integer_Address :=
        ((Last + Cache_Line - 1) / Cache_Line) * Cache_Line;
      Line : Integer_Address := First_Line;
   begin
      Dsb_Sy;
      while Line < Last_Line loop
         Dc_Ivac (To_Address (Line));
         Line := Line + Cache_Line;
      end loop;
      Dsb_Sy;
   end Sync_Buffer_From_Device;

   function Gpu_Bus_Address (Phys : System.Address) return U32 is
      P : constant U32 := U32 (To_Integer (Phys));
   begin
      return (P and 16#3FFF_FFFF#) or GPU_Uncached_Base;
   end Gpu_Bus_Address;

   procedure Flush_Rx is
      Dummy : U32;
      pragma Volatile (Dummy);
   begin
      while (Mbox0_Status and Empty_Bit) = 0 loop
         Dummy := Mbox_Read;
         Spin_Hb;
      end loop;
   end Flush_Rx;

   function Addr_Matches_Vc_Echo (Rsp, Gpu_Addr : U32) return Boolean is
      R_Frame : constant U32 := Rsp and not 16#F#;
      G_Frame : constant U32 := Gpu_Addr and not 16#F#;
   begin
      return (Rsp and 16#F#) = Channel
        and then (R_Frame and 16#3FFF_FFF0#) = (G_Frame and 16#3FFF_FFF0#);
   end Addr_Matches_Vc_Echo;

   function Call return Boolean is
      Gpu : constant U32 := Gpu_Bus_Address (Buffer'Address);
      Req : constant U32 := (Gpu and not 16#F#) or Channel;
      Rsp : U32;
   begin
      Reset_Hb;
      Pulse_Mbox_Enter;

      Flush_Rx;

      Sync_Buffer_To_Device;

      while (Mbox1_Status and Full_Bit) /= 0 loop
         Spin_Hb;
      end loop;

      Mbox_Write := Req;

      loop
         while (Mbox0_Status and Empty_Bit) /= 0 loop
            Spin_Hb;
         end loop;
         Rsp := Mbox_Read;
         exit when Addr_Matches_Vc_Echo (Rsp, Gpu);
         Spin_Hb;
      end loop;

      Sync_Buffer_From_Device;

      return Buffer (1) = 16#8000_0000#;
   end Call;

   function Tag_Response_Ok (Len_Word : U32; Min_Response_Bytes : U32)
      return Boolean
   is
      Rlen : constant U32 := Len_Word and 16#7FFF_FFFF#;
   begin
      return (Len_Word and 16#8000_0000#) /= 0
        and then Rlen >= Min_Response_Bytes;
   end Tag_Response_Ok;

end Mailbox;
