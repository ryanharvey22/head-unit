--  ui-widgets.ads — Drawing primitives built on Hal.Display

with Hal; use Hal;
with Hal.Display;
with UI.Theme;

package UI.Widgets is

   subtype Color is Hal.Display.Color;

   --  Draw an 8x16 character at pixel position (X, Y).
   --  Out-of-bounds pixels are clipped.
   procedure Put_Char (X, Y : U32; Ch : Character; Fg : Color);

   --  Draw a string starting at (X, Y).  Each character is 8 pixels wide.
   procedure Put_Text (X, Y : U32; S : String; Fg : Color);

   --  Draw an N-digit decimal number padded with spaces on the left.
   procedure Put_Number (X, Y : U32; Value : I32; Width : Positive; Fg : Color);

   --  Draw a horizontal line.
   procedure HLine (X, Y, W : U32; C : Color);

   --  Draw a vertical line.
   procedure VLine (X, Y, H : U32; C : Color);

   --  Draw a rectangle outline.
   procedure Rect (X, Y, W, H : U32; C : Color);

end UI.Widgets;
