--  ui-theme.ads — Color palette + font metrics for the head unit

with Hal.Display;

package UI.Theme is

   --  Color aliases (re-exported from Hal.Display for ergonomics)
   subtype Color is Hal.Display.Color;

   BG_Primary   : constant Color := Hal.Display.Dark_BG;
   BG_Panel     : constant Color := 16#FF22_2244#;
   FG_Primary   : constant Color := Hal.Display.White;
   FG_Secondary : constant Color := 16#FFAA_AAAA#;
   Accent       : constant Color := Hal.Display.Accent;
   Warning      : constant Color := Hal.Display.Orange;
   Critical     : constant Color := Hal.Display.Red;
   Success      : constant Color := Hal.Display.Green;

   --  Font metrics (matches the simple 8x16 bitmap font in widgets-text)
   Font_W : constant := 8;
   Font_H : constant := 16;

end UI.Theme;
