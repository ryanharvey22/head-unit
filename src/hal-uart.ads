--  hal-uart.ads — Mini-UART on GPIO 14/15 (115200) for bring-up logs

with Hal; use Hal;

package Hal.UART is

   procedure Init;

   procedure Put_Char (C : Character);
   procedure Put_String (S : String);
   procedure Put_Line (S : String);
   procedure New_Line;

   procedure Put_Hex (Value : U32);

end Hal.UART;
