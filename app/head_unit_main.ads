--  head_unit_main.ads — Target-agnostic application
--
--  Initializes all HAL subsystems and runs the main loop:
--    poll input -> dispatch events -> update screen -> draw
--
--  Same code runs on Pi, QEMU, and Sim targets.

package Head_Unit_Main is

   procedure Run;

end Head_Unit_Main;
