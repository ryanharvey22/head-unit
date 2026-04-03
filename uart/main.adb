--  main.adb — UART demo: prints to serial console
--
--  Connect a USB-to-serial adapter:
--    Pi GPIO 14 (pin 8)  → adapter RX
--    Pi GND     (pin 6)  → adapter GND
--
--  On your laptop:  screen /dev/ttyUSB0 115200
--  (or on Mac:      screen /dev/tty.usbserial-* 115200)

with Interfaces;            use Interfaces;
with System.Storage_Elements; use System.Storage_Elements;
with UART;

procedure Main is

   MMIO_Base : constant := 16#FE000000#;

   Timer_CLO : Unsigned_32;
   for Timer_CLO'Address use To_Address (MMIO_Base + 16#3004#);
   pragma Volatile (Timer_CLO);
   pragma Import (Ada, Timer_CLO);

   procedure Wait_Microseconds (Us : Unsigned_32) is
      Start : constant Unsigned_32 := Timer_CLO;
   begin
      while (Timer_CLO - Start) < Us loop
         null;
      end loop;
   end Wait_Microseconds;

   Count : Unsigned_32 := 0;

begin
   UART.Init;

   UART.New_Line;
   UART.Put_Line ("=============================");
   UART.Put_Line ("  head-unit bare-metal Ada");
   UART.Put_Line ("  Raspberry Pi 4 — BCM2711");
   UART.Put_Line ("=============================");
   UART.New_Line;
   UART.Put_Line ("UART initialized at 115200 baud.");
   UART.Put_Line ("System timer ticking at 1 MHz.");
   UART.New_Line;

   loop
      UART.Put_String ("tick ");
      UART.Put_Hex (Count);
      UART.Put_String ("  timer=");
      UART.Put_Hex (Timer_CLO);
      UART.New_Line;

      Count := Count + 1;
      Wait_Microseconds (1_000_000);  --  1 second
   end loop;
end Main;
