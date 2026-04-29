--  mailbox.adb — VideoCore mailbox implementation

with Interfaces; use Interfaces;
with System.Storage_Elements; use System.Storage_Elements;

package body Mailbox is

   MMIO_Base : constant := 16#FE000000#;
   Mbox_Base : constant := MMIO_Base + 16#B880#;

   Mbox_Read : U32;
   for Mbox_Read'Address use To_Address (Mbox_Base + 16#00#);
   pragma Volatile (Mbox_Read);
   pragma Import (Ada, Mbox_Read);

   Mbox_Status : U32;
   for Mbox_Status'Address use To_Address (Mbox_Base + 16#18#);
   pragma Volatile (Mbox_Status);
   pragma Import (Ada, Mbox_Status);

   Mbox_Write : U32;
   for Mbox_Write'Address use To_Address (Mbox_Base + 16#20#);
   pragma Volatile (Mbox_Write);
   pragma Import (Ada, Mbox_Write);

   Full_Bit  : constant U32 := 16#8000_0000#;
   Empty_Bit : constant U32 := 16#4000_0000#;
   Channel   : constant U32 := 8;

   function Call return Boolean is
      Addr    : constant U32 := U32 (To_Integer (Buffer'Address));
      Request : constant U32 := (Addr and not 16#F#) or Channel;
   begin
      while (Mbox_Status and Full_Bit) /= 0 loop
         null;
      end loop;
      Mbox_Write := Request;

      loop
         while (Mbox_Status and Empty_Bit) /= 0 loop
            null;
         end loop;
         if Mbox_Read = Request then
            return Buffer (1) = 16#8000_0000#;
         end if;
      end loop;
   end Call;

end Mailbox;
