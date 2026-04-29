--  hal-clock.adb (Pi) — System Timer at 0xFE003004, ticks at 1 MHz

with Interfaces; use Interfaces;
with System.Storage_Elements; use System.Storage_Elements;

package body Hal.Clock is

   MMIO_Base : constant := 16#FE000000#;

   Timer_CLO : U32;
   for Timer_CLO'Address use To_Address (MMIO_Base + 16#3004#);
   pragma Volatile (Timer_CLO);
   pragma Import (Ada, Timer_CLO);

   function Now_Us return U32 is
   begin
      return Timer_CLO;
   end Now_Us;

   procedure Wait_Us (Us : U32) is
      Start : constant U32 := Timer_CLO;
   begin
      while (Timer_CLO - Start) < Us loop
         null;
      end loop;
   end Wait_Us;

   procedure Wait_Ms (Ms : U32) is
   begin
      Wait_Us (Ms * 1000);
   end Wait_Ms;

end Hal.Clock;
