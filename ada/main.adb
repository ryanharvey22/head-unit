--  main.adb — Blink an LED on GPIO 17 (header pin 11)
--
--  Uses the ARM System Timer for accurate delays instead of nop counting.
--  The system timer runs at 1 MHz on all Pi 4 boards regardless of CPU clock.

with Interfaces;            use Interfaces;
with System.Storage_Elements;

procedure Main is

   use System.Storage_Elements;

   MMIO_Base : constant := 16#FE000000#;
   GPIO_Base : constant := MMIO_Base + 16#200000#;

   GPFSEL1 : Unsigned_32;
   for GPFSEL1'Address use To_Address (GPIO_Base + 16#04#);
   pragma Volatile (GPFSEL1);
   pragma Import (Ada, GPFSEL1);

   GPSET0 : Unsigned_32;
   for GPSET0'Address use To_Address (GPIO_Base + 16#1C#);
   pragma Volatile (GPSET0);
   pragma Import (Ada, GPSET0);

   GPCLR0 : Unsigned_32;
   for GPCLR0'Address use To_Address (GPIO_Base + 16#28#);
   pragma Volatile (GPCLR0);
   pragma Import (Ada, GPCLR0);

   --  System Timer counter (low 32 bits), ticks at 1 MHz
   Timer_CLO : Unsigned_32;
   for Timer_CLO'Address use To_Address (MMIO_Base + 16#3004#);
   pragma Volatile (Timer_CLO);
   pragma Import (Ada, Timer_CLO);

   LED_Bit : constant Unsigned_32 := Shift_Left (1, 17);

   procedure Wait_Microseconds (Us : Unsigned_32) is
      Start : constant Unsigned_32 := Timer_CLO;
   begin
      while (Timer_CLO - Start) < Us loop
         null;
      end loop;
   end Wait_Microseconds;

   Sel : Unsigned_32;

begin
   Sel := GPFSEL1;
   Sel := Sel and not Shift_Left (Unsigned_32'(7), 21);
   Sel := Sel or Shift_Left (Unsigned_32'(1), 21);
   GPFSEL1 := Sel;

   loop
      GPSET0 := LED_Bit;
      Wait_Microseconds (500_000);   --  500ms on
      GPCLR0 := LED_Bit;
      Wait_Microseconds (500_000);   --  500ms off
   end loop;
end Main;
