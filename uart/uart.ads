--  uart.ads — Mini-UART (UART1) driver for Raspberry Pi 4
--
--  The Pi 4 has two UARTs:
--    UART0 (PL011) — full-featured, used by Bluetooth by default
--    UART1 (mini-UART) — simpler, directly available on GPIO 14/15
--
--  We use UART1 because enable_uart=1 in config.txt sets it up for us.
--  The firmware configures GPIO 14 (TX) and 15 (RX) to alt function 5
--  and sets the baud rate clock. We just need to enable it and write bytes.
--
--  Default baud rate: 115200 (set by firmware when enable_uart=1)
--  Connect a USB-to-serial adapter:
--    Pi GPIO 14 (pin 8, TX)  → adapter RX
--    Pi GPIO 15 (pin 10, RX) → adapter TX
--    Pi GND (pin 6)          → adapter GND

with Interfaces;

package UART is

   procedure Init;
   procedure Put_Char (C : Character);
   procedure Put_String (S : String);
   procedure Put_Line (S : String);
   procedure Put_Hex (Value : Interfaces.Unsigned_32);
   procedure New_Line;

end UART;
