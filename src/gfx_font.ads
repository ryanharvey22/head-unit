--  gfx_font — 5×7 monospace bitmap font (mock UI labels; drivers fill live values later).
--
--  Attribution: see repo-root CREDITS.md (“Bitmap font”). Glyph hex tables were authored
--  for this project; conventions match common embedded 5×7 dot-matrix fonts (cf. Adafruit
--  GFX-style bitmap fonts, BSD — not a verbatim extract).

with Hal;
with Hal.Display;

package Gfx_Font is

   --  Cell advance includes one column gap at scale 1.
   Char_Cell : constant := 6;
   Char_Height_Rows : constant := 7;

   procedure Draw_Char
     (X, Y : Hal.U32; Ch : Character; FG : Hal.Display.Color; Scale : Positive := 1);

   procedure Draw_String
     (X, Y : Hal.U32; S : String; FG : Hal.Display.Color; Scale : Positive := 1);

   function Text_Width (S : String; Scale : Positive := 1) return Hal.U32;

   function Text_Height (Scale : Positive := 1) return Hal.U32;

end Gfx_Font;
