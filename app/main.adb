--  main.adb — Bare-metal entry point (called from boot.S)
--
--  boot.S calls _ada_main, which GNAT mangles from procedure Main.
--  This is used for both Pi and QEMU targets.

with Head_Unit_Main;

procedure Main is
begin
   Head_Unit_Main.Run;
   --  If Run returns we just sit here.  boot.S will park if we exit.
end Main;
