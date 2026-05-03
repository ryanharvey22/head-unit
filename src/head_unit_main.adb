--  head_unit_main.adb — Minimal firmware loop (UART / HDMI added later)

with Hal.Clock;

package body Head_Unit_Main is

   procedure Run is
   begin
      loop
         Hal.Clock.Wait_Ms (1000);
      end loop;
   end Run;

end Head_Unit_Main;
