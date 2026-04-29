--  hal-display.adb (Pi) — HDMI framebuffer via GPU mailbox

with Interfaces; use Interfaces;
with System;
with System.Storage_Elements; use System.Storage_Elements;
with Mailbox;

package body Hal.Display is

   FB_Base : System.Address := System.Null_Address;
   Pitch   : U32 := 0;

   function Init return Boolean is
      M : Mailbox.Tag_Buffer renames Mailbox.Buffer;
   begin
      M := (others => 0);

      M (0) := 35 * 4;
      M (1) := 0;

      M (2)  := 16#0004_8003#;  -- set physical size
      M (3)  := 8;
      M (4)  := 0;
      M (5)  := Width;
      M (6)  := Height;

      M (7)  := 16#0004_8004#;  -- set virtual size
      M (8)  := 8;
      M (9)  := 0;
      M (10) := Width;
      M (11) := Height;

      M (12) := 16#0004_8009#;  -- set virtual offset
      M (13) := 8;
      M (14) := 0;
      M (15) := 0;
      M (16) := 0;

      M (17) := 16#0004_8005#;  -- set depth
      M (18) := 4;
      M (19) := 0;
      M (20) := 32;

      M (21) := 16#0004_8006#;  -- set pixel order
      M (22) := 4;
      M (23) := 0;
      M (24) := 1;

      M (25) := 16#0004_0001#;  -- allocate buffer
      M (26) := 8;
      M (27) := 0;
      M (28) := 4096;
      M (29) := 0;

      M (30) := 16#0004_0008#;  -- get pitch
      M (31) := 4;
      M (32) := 0;
      M (33) := 0;

      M (34) := 0;

      if not Mailbox.Call then
         return False;
      end if;

      FB_Base := To_Address (Integer_Address (M (28) and 16#3FFF_FFFF#));
      Pitch   := M (33);

      return True;
   end Init;

   procedure Put_Pixel (X, Y : U32; C : Color) is
      Offset : Integer_Address;
   begin
      if X >= Width or else Y >= Height then
         return;
      end if;
      Offset := Integer_Address (Y * Pitch + X * 4);
      declare
         Pixel : Color;
         for Pixel'Address use FB_Base + Storage_Offset (Offset);
         pragma Volatile (Pixel);
         pragma Import (Ada, Pixel);
      begin
         Pixel := C;
      end;
   end Put_Pixel;

   procedure Fill (C : Color) is
      Addr : System.Address := FB_Base;
   begin
      for Y in 0 .. U32'(Height) - 1 loop
         for X in 0 .. U32'(Width) - 1 loop
            declare
               Pixel : Color;
               for Pixel'Address use Addr + Storage_Offset (X * 4);
               pragma Volatile (Pixel);
               pragma Import (Ada, Pixel);
            begin
               Pixel := C;
            end;
         end loop;
         Addr := Addr + Storage_Offset (Pitch);
      end loop;
   end Fill;

   procedure Fill_Rect (X, Y, W, H : U32; C : Color) is
      X2 : constant U32 := U32'Min (X + W, Width);
      Y2 : constant U32 := U32'Min (Y + H, Height);
   begin
      for Row in Y .. Y2 - 1 loop
         for Col in X .. X2 - 1 loop
            Put_Pixel (Col, Row, C);
         end loop;
      end loop;
   end Fill_Rect;

   procedure Flush is
   begin
      null;  --  Pi writes go directly to framebuffer
   end Flush;

end Hal.Display;
