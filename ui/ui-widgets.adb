--  ui-widgets.adb — Drawing primitives implementation
--
--  Bitmap font: 8x8 glyphs (one byte per row, MSB = leftmost pixel).
--  Each row is rendered twice vertically to fill the 8x16 cell.
--  Font supports: space, A-Z, 0-9, and a few punctuation marks.
--  Unsupported characters render as a hollow block.

with Interfaces; use Interfaces;
with Hal.Display;

package body UI.Widgets is

   type Glyph is array (0 .. 7) of U8;

   --  Hand-coded 8x8 glyph for a single character.  Bits set = pixel on.
   --  Layout: row 0 is top, bit 7 is leftmost pixel.
   Unknown_Glyph : constant Glyph :=
      (16#7E#, 16#42#, 16#42#, 16#42#, 16#42#, 16#42#, 16#7E#, 16#00#);

   function Glyph_For (Ch : Character) return Glyph is
   begin
      case Ch is
         when ' ' => return (others => 0);

         when 'A' | 'a' => return
            (16#3C#, 16#66#, 16#66#, 16#7E#, 16#66#, 16#66#, 16#66#, 16#00#);
         when 'B' | 'b' => return
            (16#7C#, 16#66#, 16#66#, 16#7C#, 16#66#, 16#66#, 16#7C#, 16#00#);
         when 'C' | 'c' => return
            (16#3C#, 16#66#, 16#60#, 16#60#, 16#60#, 16#66#, 16#3C#, 16#00#);
         when 'D' | 'd' => return
            (16#78#, 16#6C#, 16#66#, 16#66#, 16#66#, 16#6C#, 16#78#, 16#00#);
         when 'E' | 'e' => return
            (16#7E#, 16#60#, 16#60#, 16#7C#, 16#60#, 16#60#, 16#7E#, 16#00#);
         when 'F' | 'f' => return
            (16#7E#, 16#60#, 16#60#, 16#7C#, 16#60#, 16#60#, 16#60#, 16#00#);
         when 'G' | 'g' => return
            (16#3C#, 16#66#, 16#60#, 16#6E#, 16#66#, 16#66#, 16#3C#, 16#00#);
         when 'H' | 'h' => return
            (16#66#, 16#66#, 16#66#, 16#7E#, 16#66#, 16#66#, 16#66#, 16#00#);
         when 'I' | 'i' => return
            (16#3C#, 16#18#, 16#18#, 16#18#, 16#18#, 16#18#, 16#3C#, 16#00#);
         when 'J' | 'j' => return
            (16#1E#, 16#0C#, 16#0C#, 16#0C#, 16#0C#, 16#6C#, 16#38#, 16#00#);
         when 'K' | 'k' => return
            (16#66#, 16#6C#, 16#78#, 16#70#, 16#78#, 16#6C#, 16#66#, 16#00#);
         when 'L' | 'l' => return
            (16#60#, 16#60#, 16#60#, 16#60#, 16#60#, 16#60#, 16#7E#, 16#00#);
         when 'M' | 'm' => return
            (16#63#, 16#77#, 16#7F#, 16#6B#, 16#63#, 16#63#, 16#63#, 16#00#);
         when 'N' | 'n' => return
            (16#66#, 16#76#, 16#7E#, 16#7E#, 16#6E#, 16#66#, 16#66#, 16#00#);
         when 'O' | 'o' => return
            (16#3C#, 16#66#, 16#66#, 16#66#, 16#66#, 16#66#, 16#3C#, 16#00#);
         when 'P' | 'p' => return
            (16#7C#, 16#66#, 16#66#, 16#7C#, 16#60#, 16#60#, 16#60#, 16#00#);
         when 'Q' | 'q' => return
            (16#3C#, 16#66#, 16#66#, 16#66#, 16#6E#, 16#3C#, 16#06#, 16#00#);
         when 'R' | 'r' => return
            (16#7C#, 16#66#, 16#66#, 16#7C#, 16#78#, 16#6C#, 16#66#, 16#00#);
         when 'S' | 's' => return
            (16#3C#, 16#66#, 16#60#, 16#3C#, 16#06#, 16#66#, 16#3C#, 16#00#);
         when 'T' | 't' => return
            (16#7E#, 16#18#, 16#18#, 16#18#, 16#18#, 16#18#, 16#18#, 16#00#);
         when 'U' | 'u' => return
            (16#66#, 16#66#, 16#66#, 16#66#, 16#66#, 16#66#, 16#3C#, 16#00#);
         when 'V' | 'v' => return
            (16#66#, 16#66#, 16#66#, 16#66#, 16#66#, 16#3C#, 16#18#, 16#00#);
         when 'W' | 'w' => return
            (16#63#, 16#63#, 16#63#, 16#6B#, 16#7F#, 16#77#, 16#63#, 16#00#);
         when 'X' | 'x' => return
            (16#66#, 16#66#, 16#3C#, 16#18#, 16#3C#, 16#66#, 16#66#, 16#00#);
         when 'Y' | 'y' => return
            (16#66#, 16#66#, 16#66#, 16#3C#, 16#18#, 16#18#, 16#18#, 16#00#);
         when 'Z' | 'z' => return
            (16#7E#, 16#06#, 16#0C#, 16#18#, 16#30#, 16#60#, 16#7E#, 16#00#);

         when '0' => return
            (16#3C#, 16#66#, 16#6E#, 16#76#, 16#66#, 16#66#, 16#3C#, 16#00#);
         when '1' => return
            (16#18#, 16#38#, 16#18#, 16#18#, 16#18#, 16#18#, 16#7E#, 16#00#);
         when '2' => return
            (16#3C#, 16#66#, 16#06#, 16#0C#, 16#18#, 16#30#, 16#7E#, 16#00#);
         when '3' => return
            (16#3C#, 16#66#, 16#06#, 16#1C#, 16#06#, 16#66#, 16#3C#, 16#00#);
         when '4' => return
            (16#0C#, 16#1C#, 16#3C#, 16#6C#, 16#7E#, 16#0C#, 16#0C#, 16#00#);
         when '5' => return
            (16#7E#, 16#60#, 16#7C#, 16#06#, 16#06#, 16#66#, 16#3C#, 16#00#);
         when '6' => return
            (16#3C#, 16#66#, 16#60#, 16#7C#, 16#66#, 16#66#, 16#3C#, 16#00#);
         when '7' => return
            (16#7E#, 16#06#, 16#0C#, 16#18#, 16#30#, 16#30#, 16#30#, 16#00#);
         when '8' => return
            (16#3C#, 16#66#, 16#66#, 16#3C#, 16#66#, 16#66#, 16#3C#, 16#00#);
         when '9' => return
            (16#3C#, 16#66#, 16#66#, 16#3E#, 16#06#, 16#66#, 16#3C#, 16#00#);

         when '.' => return
            (16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#18#, 16#18#, 16#00#);
         when ',' => return
            (16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#18#, 16#18#, 16#30#);
         when ':' => return
            (16#00#, 16#18#, 16#18#, 16#00#, 16#00#, 16#18#, 16#18#, 16#00#);
         when '-' => return
            (16#00#, 16#00#, 16#00#, 16#7E#, 16#00#, 16#00#, 16#00#, 16#00#);
         when '_' => return
            (16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#FF#);
         when '/' => return
            (16#00#, 16#06#, 16#0C#, 16#18#, 16#30#, 16#60#, 16#00#, 16#00#);
         when '+' => return
            (16#00#, 16#18#, 16#18#, 16#7E#, 16#18#, 16#18#, 16#00#, 16#00#);
         when '*' => return
            (16#00#, 16#66#, 16#3C#, 16#FF#, 16#3C#, 16#66#, 16#00#, 16#00#);
         when '(' => return
            (16#0C#, 16#18#, 16#30#, 16#30#, 16#30#, 16#18#, 16#0C#, 16#00#);
         when ')' => return
            (16#30#, 16#18#, 16#0C#, 16#0C#, 16#0C#, 16#18#, 16#30#, 16#00#);
         when '!' => return
            (16#18#, 16#18#, 16#18#, 16#18#, 16#00#, 16#18#, 16#18#, 16#00#);
         when '?' => return
            (16#3C#, 16#66#, 16#06#, 16#0C#, 16#18#, 16#00#, 16#18#, 16#00#);
         when '%' => return
            (16#62#, 16#66#, 16#0C#, 16#18#, 16#30#, 16#66#, 16#46#, 16#00#);

         when others => return Unknown_Glyph;
      end case;
   end Glyph_For;

   procedure Put_Char (X, Y : U32; Ch : Character; Fg : Color) is
      G  : constant Glyph := Glyph_For (Ch);
      Row : U8;
   begin
      for Dy in 0 .. 7 loop
         Row := G (Dy);
         for Dx in 0 .. 7 loop
            if (Shift_Right (Row, 7 - Dx) and 1) /= 0 then
               --  Render each font row as 2 screen rows for 8x16 height
               Hal.Display.Put_Pixel (X + U32 (Dx), Y + U32 (Dy * 2),     Fg);
               Hal.Display.Put_Pixel (X + U32 (Dx), Y + U32 (Dy * 2) + 1, Fg);
            end if;
         end loop;
      end loop;
   end Put_Char;

   procedure Put_Text (X, Y : U32; S : String; Fg : Color) is
      Cx : U32 := X;
   begin
      for I in S'Range loop
         Put_Char (Cx, Y, S (I), Fg);
         Cx := Cx + U32 (Theme.Font_W);
      end loop;
   end Put_Text;

   procedure Put_Number (X, Y : U32; Value : I32; Width : Positive; Fg : Color) is
      Buf      : String (1 .. Width);
      Pos      : Natural := Buf'Last;
      V        : I32 := Value;
      Negative : Boolean := False;
   begin
      Buf := (others => ' ');
      if V = 0 then
         Buf (Pos) := '0';
         Pos := Pos - 1;
      else
         if V < 0 then
            Negative := True;
            V := -V;
         end if;
         while V > 0 and Pos >= Buf'First loop
            Buf (Pos) := Character'Val (Character'Pos ('0') + Integer (V rem 10));
            V := V / 10;
            Pos := Pos - 1;
         end loop;
         if Negative and Pos >= Buf'First then
            Buf (Pos) := '-';
         end if;
      end if;
      Put_Text (X, Y, Buf, Fg);
   end Put_Number;

   procedure HLine (X, Y, W : U32; C : Color) is
   begin
      for I in 0 .. W - 1 loop
         Hal.Display.Put_Pixel (X + I, Y, C);
      end loop;
   end HLine;

   procedure VLine (X, Y, H : U32; C : Color) is
   begin
      for I in 0 .. H - 1 loop
         Hal.Display.Put_Pixel (X, Y + I, C);
      end loop;
   end VLine;

   procedure Rect (X, Y, W, H : U32; C : Color) is
   begin
      HLine (X, Y, W, C);
      HLine (X, Y + H - 1, W, C);
      VLine (X, Y, H, C);
      VLine (X + W - 1, Y, H, C);
   end Rect;

end UI.Widgets;
