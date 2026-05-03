--  hal-display.ads — HDMI framebuffer via VideoCore mailbox (property tags)

with Hal; use Hal;

package Hal.Display is

   --  XRGB: keep alpha byte 0 for legacy mailbox scan-out.
   subtype Color is U32;

   Black   : constant Color := 16#0000_0000#;
   White   : constant Color := 16#00FF_FFFF#;
   Red     : constant Color := 16#00FF_0000#;
   Green   : constant Color := 16#0000_FF00#;
   Blue    : constant Color := 16#0000_00FF#;
   Magenta : constant Color := 16#00FF_00FF#;
   Yellow  : constant Color := 16#00FF_FF00#;

   --  Requested mode (must match config.txt / firmware timing hints).
   Width  : constant := 640;
   Height : constant := 480;

   function Init return Boolean;

   procedure Fill (C : Color);
   procedure Put_Pixel (X, Y : U32; C : Color);

   --  Drain CPU write buffers before scan-out reads framebuffer RAM.
   procedure Flush;

   function Last_Phys_Width return U32;
   function Last_Phys_Height return U32;
   function Last_FB_Address return U32;
   function Last_Scanline_Pitch return U32;

end Hal.Display;
