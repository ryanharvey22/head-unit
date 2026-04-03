--  main.adb — FFT test: generate a known signal, run FFT, print results
--
--  Test signal: sum of two sine waves at known frequencies.
--  After FFT, output the magnitude of each bin over UART.
--  Verify on the laptop that peaks appear at the correct bins.
--
--  Connect USB-to-serial adapter:
--    Pi GPIO 14 (pin 8)  → adapter RX
--    Pi GND     (pin 6)  → adapter GND
--    Laptop: screen /dev/ttyUSB0 115200

with Interfaces;            use Interfaces;
with System.Storage_Elements; use System.Storage_Elements;
with UART;
with FFT;
with Fixed_Point;

procedure Main is

   MMIO_Base : constant := 16#FE000000#;

   Timer_CLO : Unsigned_32;
   for Timer_CLO'Address use To_Address (MMIO_Base + 16#3004#);
   pragma Volatile (Timer_CLO);
   pragma Import (Ada, Timer_CLO);

   N : constant := 256;

   Signal : FFT.Complex_Array (0 .. N - 1);
   Mag    : FFT.Magnitude_Array (0 .. N - 1);

begin
   UART.Init;

   UART.New_Line;
   UART.Put_Line ("=============================");
   UART.Put_Line ("  FFT Test — bare-metal Ada");
   UART.Put_Line ("=============================");
   UART.New_Line;

   --  TODO: generate test signal (two sine waves)
   --  TODO: run FFT.Forward on Signal
   --  TODO: compute FFT.Magnitude_Sq
   --  TODO: print each bin's magnitude over UART
   --  TODO: verify peaks at expected frequency bins

   UART.Put_Line ("FFT not yet implemented. Fill in the TODOs!");

   loop
      null;
   end loop;
end Main;
