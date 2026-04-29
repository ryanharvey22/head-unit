--  hal-uart.ads — Debug serial output abstraction
--
--  Pi:    mini-UART (UART1) on GPIO 14/15 at 115200 baud
--  QEMU:  same mini-UART, output appears on stdio via -serial stdio
--  Sim:   prints to host stdout

with Hal; use Hal;

package Hal.UART is

   procedure Init;

   procedure Put_Char (C : Character);
   procedure Put_String (S : String);
   procedure Put_Line (S : String);
   procedure New_Line;

   procedure Put_Hex (Value : U32);
   procedure Put_Decimal (Value : I32);

end Hal.UART;
