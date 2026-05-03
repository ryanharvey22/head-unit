--  gfx_font.adb — bitmap blit via Hal.Display.Fill_Rect
--
--  Credits: CREDITS.md — Raspberry Pi / Adafruit GFX references for font style context.

with Interfaces; use Interfaces;

package body Gfx_Font is

   use type Hal.U32;

   subtype Row_Byte is Unsigned_8;
   type Glyph_Rows is array (0 .. 6) of Row_Byte;

   Glyph_Table : constant array (0 .. 48) of Glyph_Rows :=
     (
      (16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#),
      (16#0E#, 16#11#, 16#11#, 16#11#, 16#11#, 16#11#, 16#0E#),
      (16#04#, 16#0C#, 16#04#, 16#04#, 16#04#, 16#04#, 16#0E#),
      (16#0E#, 16#11#, 16#01#, 16#02#, 16#04#, 16#08#, 16#1F#),
      (16#1E#, 16#01#, 16#01#, 16#0E#, 16#01#, 16#01#, 16#1E#),
      (16#02#, 16#06#, 16#0A#, 16#12#, 16#1F#, 16#02#, 16#02#),
      (16#1F#, 16#10#, 16#10#, 16#1E#, 16#01#, 16#01#, 16#1E#),
      (16#06#, 16#08#, 16#10#, 16#1E#, 16#11#, 16#11#, 16#0E#),
      (16#1F#, 16#01#, 16#02#, 16#04#, 16#04#, 16#04#, 16#04#),
      (16#0E#, 16#11#, 16#11#, 16#0E#, 16#11#, 16#11#, 16#0E#),
      (16#0E#, 16#11#, 16#11#, 16#0F#, 16#01#, 16#02#, 16#0C#),
      (16#0E#, 16#11#, 16#11#, 16#1F#, 16#11#, 16#11#, 16#11#),
      (16#1E#, 16#11#, 16#11#, 16#1E#, 16#11#, 16#11#, 16#1E#),
      (16#0E#, 16#11#, 16#10#, 16#10#, 16#10#, 16#11#, 16#0E#),
      (16#1C#, 16#12#, 16#11#, 16#11#, 16#11#, 16#12#, 16#1C#),
      (16#1F#, 16#10#, 16#10#, 16#1E#, 16#10#, 16#10#, 16#1F#),
      (16#1F#, 16#10#, 16#10#, 16#1E#, 16#10#, 16#10#, 16#10#),
      (16#0E#, 16#11#, 16#10#, 16#17#, 16#11#, 16#11#, 16#0F#),
      (16#11#, 16#11#, 16#11#, 16#1F#, 16#11#, 16#11#, 16#11#),
      (16#0E#, 16#04#, 16#04#, 16#04#, 16#04#, 16#04#, 16#0E#),
      (16#07#, 16#02#, 16#02#, 16#02#, 16#02#, 16#12#, 16#0C#),
      (16#11#, 16#12#, 16#14#, 16#18#, 16#14#, 16#12#, 16#11#),
      (16#10#, 16#10#, 16#10#, 16#10#, 16#10#, 16#10#, 16#1F#),
      (16#11#, 16#1B#, 16#15#, 16#15#, 16#11#, 16#11#, 16#11#),
      (16#11#, 16#19#, 16#15#, 16#13#, 16#11#, 16#11#, 16#11#),
      (16#0E#, 16#11#, 16#11#, 16#11#, 16#11#, 16#11#, 16#0E#),
      (16#1E#, 16#11#, 16#11#, 16#1E#, 16#10#, 16#10#, 16#10#),
      (16#0E#, 16#11#, 16#11#, 16#11#, 16#15#, 16#12#, 16#0D#),
      (16#1E#, 16#11#, 16#11#, 16#1E#, 16#14#, 16#12#, 16#11#),
      (16#0F#, 16#10#, 16#10#, 16#0E#, 16#01#, 16#01#, 16#1E#),
      (16#1F#, 16#04#, 16#04#, 16#04#, 16#04#, 16#04#, 16#04#),
      (16#11#, 16#11#, 16#11#, 16#11#, 16#11#, 16#11#, 16#0E#),
      (16#11#, 16#11#, 16#11#, 16#11#, 16#11#, 16#0A#, 16#04#),
      (16#11#, 16#11#, 16#11#, 16#15#, 16#15#, 16#15#, 16#0A#),
      (16#11#, 16#11#, 16#0A#, 16#04#, 16#0A#, 16#11#, 16#11#),
      (16#11#, 16#11#, 16#0A#, 16#04#, 16#04#, 16#04#, 16#04#),
      (16#1F#, 16#01#, 16#02#, 16#04#, 16#08#, 16#10#, 16#1F#),
      (16#00#, 16#00#, 16#00#, 16#00#, 16#06#, 16#06#, 16#08#),
      (16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#0C#, 16#0C#),
      (16#0C#, 16#0C#, 16#00#, 16#00#, 16#0C#, 16#0C#, 16#00#),
      (16#00#, 16#00#, 16#00#, 16#1F#, 16#00#, 16#00#, 16#00#),
      (16#00#, 16#04#, 16#04#, 16#1F#, 16#04#, 16#04#, 16#00#),
      (16#01#, 16#02#, 16#04#, 16#08#, 16#10#, 16#00#, 16#00#),
      (16#19#, 16#1A#, 16#04#, 16#08#, 16#16#, 16#13#, 16#00#),
      (16#0E#, 16#08#, 16#08#, 16#08#, 16#08#, 16#08#, 16#0E#),
      (16#0E#, 16#02#, 16#02#, 16#02#, 16#02#, 16#02#, 16#0E#),
      (16#02#, 16#04#, 16#08#, 16#08#, 16#08#, 16#04#, 16#02#),
      (16#08#, 16#04#, 16#02#, 16#02#, 16#02#, 16#04#, 16#08#),
      (16#00#, 16#1F#, 16#00#, 16#1F#, 16#00#, 16#00#, 16#00#));

   Glyph_Map : constant String :=
     " 0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ,.:-+/%[]()=";

   function Glyph_Index (Ch : Character) return Natural is
      U : Character := Ch;
   begin
      if Ch in 'a' .. 'z' then
         U := Character'Val (Character'Pos (Ch) - 32);
      end if;
      for J in Glyph_Map'Range loop
         if Glyph_Map (J) = U then
            return J - Glyph_Map'First;
         end if;
      end loop;
      return 0;
   end Glyph_Index;

   procedure Draw_Char
     (X, Y : Hal.U32; Ch : Character; FG : Hal.Display.Color; Scale : Positive := 1)
   is
      Idx  : constant Natural := Glyph_Index (Ch);
      G    : Glyph_Rows renames Glyph_Table (Idx);
      S    : constant Hal.U32 := Hal.U32 (Scale);
      Mask : Unsigned_8;
   begin
      for RR in G'Range loop
         Mask := G (RR);
         for Col in 0 .. 4 loop
            if (Shift_Right (Mask, Natural (4 - Col)) and 1) /= 0 then
               Hal.Display.Fill_Rect
                 (X + Hal.U32 (Col) * S,
                  Y + Hal.U32 (Natural (RR)) * S,
                  S,
                  S,
                  FG);
            end if;
         end loop;
      end loop;
   end Draw_Char;

   procedure Draw_String
     (X, Y : Hal.U32; S : String; FG : Hal.Display.Color; Scale : Positive := 1)
   is
      CX : Hal.U32 := X;
      Adv : constant Hal.U32 := Hal.U32 (Char_Cell * Scale);
   begin
      for I in S'Range loop
         Draw_Char (CX, Y, S (I), FG, Scale);
         CX := CX + Adv;
      end loop;
   end Draw_String;

   function Text_Width (S : String; Scale : Positive := 1) return Hal.U32 is
   begin
      return Hal.U32 (S'Length * Char_Cell * Scale);
   end Text_Width;

   function Text_Height (Scale : Positive := 1) return Hal.U32 is
   begin
      return Hal.U32 (Char_Height_Rows * Scale);
   end Text_Height;

end Gfx_Font;
