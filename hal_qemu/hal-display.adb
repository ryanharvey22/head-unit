--  hal-display.adb (QEMU) — STUB
--
--  QEMU's Pi 4 framebuffer emulation is incomplete and unreliable.
--  We use QEMU mainly for testing boot/UART/CPU logic.  Display
--  operations are no-ops here; use Hal.UART for textual output.

package body Hal.Display is

   function Init return Boolean is
   begin
      return True;
   end Init;

   procedure Put_Pixel (X, Y : U32; C : Color) is
      pragma Unreferenced (X, Y, C);
   begin
      null;
   end Put_Pixel;

   procedure Fill (C : Color) is
      pragma Unreferenced (C);
   begin
      null;
   end Fill;

   procedure Fill_Rect (X, Y, W, H : U32; C : Color) is
      pragma Unreferenced (X, Y, W, H, C);
   begin
      null;
   end Fill_Rect;

   procedure Flush is
   begin
      null;
   end Flush;

end Hal.Display;
