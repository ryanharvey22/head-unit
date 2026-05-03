--  hal-display.adb — Mailbox framebuffer (property tags per firmware wiki +
--  rockytriton part14-style sequence: alpha ignored, blank off, allocate, pitch).

with Interfaces; use Interfaces;
with System.Machine_Code;
with System;
with System.Storage_Elements; use System.Storage_Elements;
with Hal.Clock;
with Hal.GPIO;
with Mailbox;

package body Hal.Display is

   use type System.Address;

   FB_Base     : System.Address := System.Null_Address;
   FB_Addr_U32 : U32             := 0;
   Pitch       : U32             := 0;
   Last_PW     : U32             := 0;
   Last_PH     : U32             := 0;

   function Last_Phys_Width return U32 is (Last_PW);
   function Last_Phys_Height return U32 is (Last_PH);
   function Last_FB_Address return U32 is (FB_Addr_U32);
   function Last_Scanline_Pitch return U32 is (Pitch);

   procedure Dsb_Sy is
   begin
      System.Machine_Code.Asm ("dsb sy", Volatile => True, Clobber => "memory");
   end Dsb_Sy;

   function Init return Boolean is
      M : Mailbox.Tag_Buffer renames Mailbox.Buffer;

      procedure Blip (On_Loops, Off_Loops : Natural) is
      begin
         Hal.GPIO.Write (Hal.GPIO.Debug_LED_BCM, True);
         Hal.Clock.Busy_Wait_Loops (On_Loops);
         Hal.GPIO.Write (Hal.GPIO.Debug_LED_BCM, False);
         Hal.Clock.Busy_Wait_Loops (Off_Loops);
      end Blip;

      Phys_W    : U32;
      Phys_H    : U32;
      FB_Ptr    : U32;
      Row_Pitch : U32;

      Tag_End : constant Natural := 42;
      Raw_Bytes : constant Natural := (Tag_End + 1) * 4;
      Buf_Bytes : constant U32 :=
        U32 ((Raw_Bytes + 15) / 16 * 16);
   begin
      --  Milestone: entered Init (GPIO already configured in main).
      Blip (10_000_000, 6_000_000);

      --  Clear tag buffer with stores only — avoids memset path / aggregate quirks.
      for I in M'Range loop
         M (I) := 0;
      end loop;

      Blip (4_000_000, 3_000_000);

      M (0) := Buf_Bytes;
      M (1) := 0;

      --  Set physical size (0x00048003)
      M (2)  := 16#0004_8003#;
      M (3)  := 8;
      M (4)  := 8;
      M (5)  := Width;
      M (6)  := Height;

      --  Set virtual size (0x00048004)
      M (7)  := 16#0004_8004#;
      M (8)  := 8;
      M (9)  := 8;
      M (10) := Width;
      M (11) := Height;

      --  Set virtual offset (0x00048009)
      M (12) := 16#0004_8009#;
      M (13) := 8;
      M (14) := 8;
      M (15) := 0;
      M (16) := 0;

      --  Set depth (0x00048005)
      M (17) := 16#0004_8005#;
      M (18) := 4;
      M (19) := 4;
      M (20) := 32;

      --  Set pixel order RGB (0x00048006)
      M (21) := 16#0004_8006#;
      M (22) := 4;
      M (23) := 4;
      M (24) := 1;

      --  Set alpha mode (0x00048007): 0 = alpha channel ignored
      M (25) := 16#0004_8007#;
      M (26) := 4;
      M (27) := 4;
      M (28) := 0;

      --  Blank screen off (0x00040002)
      M (29) := 16#0004_0002#;
      M (30) := 4;
      M (31) := 4;
      M (32) := 0;

      --  Allocate buffer (0x00040001); request = alignment only
      M (33) := 16#0004_0001#;
      M (34) := 8;
      M (35) := 4;
      M (36) := 4096;
      M (37) := 0;

      --  Get pitch (0x00040008)
      M (38) := 16#0004_0008#;
      M (39) := 4;
      M (40) := 0;
      M (41) := 0;

      M (42) := 0;

      Last_PW := 0;
      Last_PH := 0;

      Blip (2_500_000, 2_500_000);
      Blip (2_500_000, 2_500_000);

      if not Mailbox.Call then
         FB_Base     := System.Null_Address;
         FB_Addr_U32 := 0;
         Pitch       := 0;
         return False;
      end if;

      if not Mailbox.Tag_Response_Ok (M (35), 8)
        or else not Mailbox.Tag_Response_Ok (M (40), 4)
      then
         FB_Base     := System.Null_Address;
         FB_Addr_U32 := 0;
         Pitch       := 0;
         return False;
      end if;

      Phys_W := M (5);
      Phys_H := M (6);
      if Phys_W = 0 or else Phys_H = 0 then
         FB_Base     := System.Null_Address;
         FB_Addr_U32 := 0;
         Pitch       := 0;
         return False;
      end if;

      FB_Ptr := M (36) and 16#3FFF_FFFF#;
      Row_Pitch := M (41);
      if FB_Ptr = 0 or else Row_Pitch = 0 then
         FB_Base     := System.Null_Address;
         FB_Addr_U32 := 0;
         Pitch       := 0;
         return False;
      end if;

      FB_Addr_U32 := FB_Ptr;
      FB_Base     := To_Address (Integer_Address (FB_Ptr));
      Pitch       := Row_Pitch;
      Last_PW     := Phys_W;
      Last_PH     := Phys_H;

      return True;
   end Init;

   procedure Put_Pixel (X, Y : U32; C : Color) is
      Offset : Integer_Address;
   begin
      if FB_Base = System.Null_Address then
         return;
      end if;
      if X >= Last_PW or else Y >= Last_PH then
         return;
      end if;
      Offset := Integer_Address (Y * Pitch + X * 4);
      declare
         Pixel : Color;
         for Pixel'Address use FB_Base + Storage_Offset (Offset);
         pragma Volatile (Pixel);
         pragma Import (Ada, Pixel);
      begin
         Pixel := C;
      end;
   end Put_Pixel;

   procedure Fill (C : Color) is
      Addr : System.Address := FB_Base;
   begin
      if FB_Base = System.Null_Address then
         return;
      end if;
      for Y in 0 .. Last_PH - 1 loop
         for X in 0 .. Last_PW - 1 loop
            declare
               Pixel : Color;
               for Pixel'Address use Addr + Storage_Offset (Integer_Address (X * 4));
               pragma Volatile (Pixel);
               pragma Import (Ada, Pixel);
            begin
               Pixel := C;
            end;
         end loop;
         Addr := Addr + Storage_Offset (Pitch);
      end loop;
   end Fill;

   procedure Flush is
   begin
      Dsb_Sy;
   end Flush;

end Hal.Display;
