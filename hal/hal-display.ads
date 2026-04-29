--  hal-display.ads — Display abstraction
--
--  Pi:    HDMI framebuffer via GPU mailbox at 640x480x32
--  QEMU:  stub (Pi 4 framebuffer in QEMU is unreliable)
--  Sim:   SDL2 window with software texture, presented per Flush

with Hal; use Hal;

package Hal.Display is

   --  Pixel format: 0xAARRGGBB (alpha most-significant)
   subtype Color is U32;

   --  Predefined colors for convenience
   Black   : constant Color := 16#FF00_0000#;
   White   : constant Color := 16#FFFF_FFFF#;
   Red     : constant Color := 16#FFFF_0000#;
   Green   : constant Color := 16#FF00_FF00#;
   Blue    : constant Color := 16#FF00_00FF#;
   Yellow  : constant Color := 16#FFFF_FF00#;
   Cyan    : constant Color := 16#FF00_FFFF#;
   Magenta : constant Color := 16#FFFF_00FF#;
   Orange  : constant Color := 16#FFFF_8000#;
   Gray    : constant Color := 16#FF80_8080#;
   Dark_BG : constant Color := 16#FF1A_1A2E#;
   Accent  : constant Color := 16#FF3A_86FF#;

   --  Fixed display size for the head unit.  Real Pi gets 640x480 from GPU,
   --  sim opens a 640x480 SDL2 window.  Stays consistent across targets.
   Width  : constant := 640;
   Height : constant := 480;

   --  Initialize display.  Returns True on success.
   function Init return Boolean;

   --  Set a single pixel.  Bounds-checked: out-of-range coordinates are no-ops.
   procedure Put_Pixel (X, Y : U32; C : Color);

   --  Fill the entire screen with a solid color.
   procedure Fill (C : Color);

   --  Draw a filled rectangle.  Clipped to screen bounds.
   procedure Fill_Rect (X, Y, W, H : U32; C : Color);

   --  Present any pending pixel writes to the screen.
   --  Pi:  no-op (writes go directly to framebuffer)
   --  Sim: SDL_RenderPresent
   procedure Flush;

end Hal.Display;
