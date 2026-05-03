--  screen_background.adb — Tile geometry + static drawing (no text yet).

with Hal.Display;
with Gfx_Font;

package body Screen_Background is

   use type Hal.U32;

   Pad      : constant Hal.U32 := 0;
   Gap      : constant Hal.U32 := 8;
   Top_H    : constant Hal.U32 := 42;
   Bottom_H : constant Hal.U32 := 36;

   Inner_W   : Hal.U32 := Hal.Display.Width;
   Left_W    : Hal.U32 := 0;
   Right_W   : Hal.U32 := 0;
   Main_Y    : Hal.U32 := 0;
   Main_H    : Hal.U32 := 0;
   Bottom_Y  : Hal.U32 := 0;
   Right_X   : Hal.U32 := 0;
   Cur_FB_H  : Hal.U32 := Hal.Display.Height;

   Diag_Title_H : constant Hal.U32 := 26;

   procedure Sync_Layout_From_FB is
      W : constant Hal.U32 := Hal.Display.Last_Phys_Width;
      H : constant Hal.U32 := Hal.Display.Last_Phys_Height;
   begin
      if W = 0 or H = 0 then
         Inner_W  := Hal.Display.Width - 2 * Pad;
         Cur_FB_H := Hal.Display.Height;
      else
         Inner_W  := W - 2 * Pad;
         Cur_FB_H := H;
      end if;

      Left_W := (Inner_W * 408) / 640;
      if Left_W + Gap < Inner_W then
         Right_W := Inner_W - Left_W - Gap;
      else
         Left_W   := Inner_W / 2;
         Right_W  := Inner_W - Left_W - Gap;
      end if;

      Main_Y   := Pad + Top_H + Gap;
      Main_H   := Cur_FB_H - Main_Y - Gap - Bottom_H - Pad;
      Bottom_Y := Main_Y + Main_H + Gap;
      Right_X  := Pad + Left_W + Gap;
   end Sync_Layout_From_FB;

   function C (V : Hal.U32) return Hal.Display.Color is (Hal.Display.Color (V));

   function Tile (Id : Tile_Id) return Region is
   begin
      case Id is
         when Top_Status =>
            return Region'(Pad, Pad, Inner_W, Top_H);
         when Left_Speed =>
            return Region'(Pad, Main_Y, Left_W, Main_H);
         when Right_Diagnostics =>
            return Region'(Right_X, Main_Y, Right_W, Main_H);
         when Bottom_Trip =>
            return Region'(Pad, Bottom_Y, Inner_W, Bottom_H);
      end case;
   end Tile;

   function Diag_Row (Row : Diag_Row_Index) return Region is
      R         : constant Region := Tile (Right_Diagnostics);
      Body_H    : constant Hal.U32 := R.H - Diag_Title_H - 4;
      Row_H     : constant Hal.U32 := Body_H / 5;
      Slack     : constant Hal.U32 := Body_H - Row_H * 5;
      Y_Base    : constant Hal.U32 := R.Y + Diag_Title_H + 2;
      This_Y    : constant Hal.U32 := Y_Base + Hal.U32 (Row) * Row_H;
      Extra     : constant Hal.U32 := (if Row = 4 then Slack else 0);
   begin
      return Region'(R.X + 2, This_Y, R.W - 4, Row_H + Extra);
   end Diag_Row;

   procedure Subtle_Topo_Lines is
      Step : constant Hal.U32 := 14;
      Y    : Hal.U32 := Pad;
   begin
      while Y < Cur_FB_H - Pad loop
         Hal.Display.Fill_Rect (Pad, Y, Inner_W, 1, C (Topo_Overlay));
         Y := Y + Step;
      end loop;
   end Subtle_Topo_Lines;

   procedure Draw_Brackets (T : Region; Arm : Hal.U32; Th : Hal.U32; Col : Hal.U32) is
      Inset : constant Hal.U32 := 10;
      X0    : constant Hal.U32 := T.X + Inset;
      Y0    : constant Hal.U32 := T.Y + Inset;
      X1    : constant Hal.U32 := T.X + T.W - Inset - Arm;
      Y1    : constant Hal.U32 := T.Y + T.H - Inset - Arm;
   begin
      --  Top-left
      Hal.Display.Fill_Rect (X0, Y0, Arm, Th, C (Col));
      Hal.Display.Fill_Rect (X0, Y0, Th, Arm, C (Col));
      --  Top-right
      Hal.Display.Fill_Rect (X1, Y0, Arm, Th, C (Col));
      Hal.Display.Fill_Rect (X1 + Arm - Th, Y0, Th, Arm, C (Col));
      --  Bottom-left
      Hal.Display.Fill_Rect (X0, Y1 + Arm - Th, Arm, Th, C (Col));
      Hal.Display.Fill_Rect (X0, Y1, Th, Arm, C (Col));
      --  Bottom-right
      Hal.Display.Fill_Rect (X1, Y1 + Arm - Th, Arm, Th, C (Col));
      Hal.Display.Fill_Rect (X1 + Arm - Th, Y1, Th, Arm, C (Col));
   end Draw_Brackets;

   procedure Seg_H_Bar
     (R          : Region;
      Bar_H      : Hal.U32;
      Seg_W      : Hal.U32;
      Seg_Gap    : Hal.U32;
      Fill_Count : Hal.U32;
      On_C       : Hal.U32;
      Off_C      : Hal.U32)
   is
      TW    : Hal.U32 := 0;
      Nseg  : Hal.U32 := 0;
      Next_TH : Hal.U32;
      X0    : Hal.U32;
      Y_B   : Hal.U32;
      X     : Hal.U32;
      K     : Hal.U32;
   begin
      loop
         if Nseg = 0 then
            exit when Seg_W > R.W;
            TW := Seg_W;
            Nseg := 1;
         else
            Next_TH := TW + Seg_Gap + Seg_W;
            exit when Next_TH > R.W;
            TW := Next_TH;
            Nseg := Nseg + 1;
         end if;
      end loop;

      if Nseg = 0 then
         return;
      end if;

      X0 := R.X + (R.W - TW) / 2;
      Y_B := R.Y + (R.H - Bar_H) / 2;
      X := X0;
      K := 0;
      while K < Nseg loop
         if K < Fill_Count then
            Hal.Display.Fill_Rect (X, Y_B, Seg_W, Bar_H, C (On_C));
         else
            Hal.Display.Fill_Rect (X, Y_B, Seg_W, Bar_H, C (Off_C));
         end if;
         X := X + Seg_W + Seg_Gap;
         K := K + 1;
      end loop;
   end Seg_H_Bar;

   procedure Seg_V_Bar_Left
     (R          : Region;
      Bar_W      : Hal.U32;
      Seg_H      : Hal.U32;
      Seg_Gap    : Hal.U32;
      Fill_Count : Hal.U32;
      On_C       : Hal.U32;
      Off_C      : Hal.U32)
   is
      Margin_T  : constant Hal.U32 := 8;
      Margin_B  : constant Hal.U32 := 8;
      Avail_V   : constant Hal.U32 := R.H - Margin_T - Margin_B;
      TH        : Hal.U32 := 0;
      N_Max     : Hal.U32 := 0;
      Next_TH   : Hal.U32;
      Y_Top_Block : Hal.U32;
      X_B       : Hal.U32;
      J         : Hal.U32;
      Y_Seg     : Hal.U32;
   begin
      loop
         if N_Max = 0 then
            exit when Seg_H > Avail_V;
            TH := Seg_H;
            N_Max := 1;
         else
            Next_TH := TH + Seg_Gap + Seg_H;
            exit when Next_TH > Avail_V;
            TH := Next_TH;
            N_Max := N_Max + 1;
         end if;
      end loop;

      if N_Max = 0 then
         return;
      end if;

      Y_Top_Block := R.Y + Margin_T + (Avail_V - TH) / 2;
      X_B := R.X + (R.W - Bar_W) / 2;

      J := 0;
      while J < N_Max loop
         Y_Seg := Y_Top_Block + TH - Seg_H - J * (Seg_Gap + Seg_H);
         if J < Fill_Count then
            Hal.Display.Fill_Rect (X_B, Y_Seg, Bar_W, Seg_H, C (On_C));
         else
            Hal.Display.Fill_Rect (X_B, Y_Seg, Bar_W, Seg_H, C (Off_C));
         end if;
         J := J + 1;
      end loop;
   end Seg_V_Bar_Left;

   procedure Draw_Diag_Rows is
      Row_H    : Hal.U32;
      TextBand : Hal.U32;
      Bar_Top  : Hal.U32;
      Bar_Hgt  : Hal.U32;
      R_Bar    : Region;
   begin
      for I in Diag_Row_Index loop
         declare
            R : constant Region := Diag_Row (I);
         begin
            Row_H := R.H;
            if I < 4 then
               Hal.Display.Fill_Rect (R.X, R.Y + Row_H - 1, R.W, 1, C (Divider));
            end if;

            TextBand := Row_H * 40 / 100;
            Bar_Top := R.Y + TextBand + 2;
            Bar_Hgt := Row_H - TextBand - 4;
            R_Bar := Region'(R.X, Bar_Top, R.W, Bar_Hgt);

            case I is
               when 0 =>
                  Seg_H_Bar (R_Bar, 6, 5, 2, 10, Accent, Divider);
               when 1 =>
                  Seg_V_Bar_Left (R_Bar, 4, 7, 2, 8, Accent, Divider);
               when 2 =>
                  Seg_H_Bar (R_Bar, 6, 5, 2, 14, Accent, Divider);
               when 3 =>
                  Seg_H_Bar (R_Bar, 6, 5, 2, 11, Status_OK, Divider);
               when 4 =>
                  Seg_H_Bar (R_Bar, 6, 5, 2, 9, Accent, Divider);
            end case;
         end;
      end loop;
   end Draw_Diag_Rows;

   procedure Bottom_Ruler (B : Region) is
      NX    : Hal.U32 := B.X + 1;
      Max_X : constant Hal.U32 := B.X + B.W - 1;
      Pat   : Hal.U32;
      Ht    : Hal.U32;
   begin
      while NX < Max_X loop
         Pat := (NX / 7) mod 4;
         case Pat is
            when 0 => Ht := 10;
            when 1 => Ht := 6;
            when 2 => Ht := 14;
            when others => Ht := 8;
         end case;
         Hal.Display.Fill_Rect (NX, B.Y + B.H - Ht - 4, 2, Ht, C (Accent));
         NX := NX + 5;
      end loop;
   end Bottom_Ruler;

   procedure Draw_Mock_Text is
      use type Hal.U32;

      Speed_Scale : constant Positive := 5;

      TH1 : constant Hal.U32 := Gfx_Font.Text_Height (1);
      TH2 : constant Hal.U32 := Gfx_Font.Text_Height (2);
      TH5 : constant Hal.U32 := Gfx_Font.Text_Height (Speed_Scale);

      function FC (U : Hal.U32) return Hal.Display.Color is (Hal.Display.Color (U));

      function CX (RX, RW, TextW : Hal.U32) return Hal.U32 is (RX + (RW - TextW) / 2);
      function CY (RY, RH, TexH : Hal.U32) return Hal.U32 is (RY + (RH - TexH) / 2);

      T  : Region;
      L  : Region;
      R  : Region;
      B  : Region;
      DR : Region;

      W3      : Hal.U32;
      RW_Right : Hal.U32;
      RX_Right : Hal.U32;
      TW      : Hal.U32;
      StackH  : Hal.U32;
      Y0      : Hal.U32;
      Upper_H : Hal.U32;
      Lower_Y : Hal.U32;
      Lower_H : Hal.U32;
      RowW    : Hal.U32;
      RowH_Spd : Hal.U32;
      GapLbl  : constant Hal.U32 := 14;
      IX      : Hal.U32;
      IY      : Hal.U32;
      IW      : Hal.U32;
      IH      : Hal.U32;
      LW      : Hal.U32;
      VW      : Hal.U32;
      TW_Line : Hal.U32;
      TX0     : Hal.U32;
      TY_Text : Hal.U32;
      Trip_TW : Hal.U32;
      Text_Zone_H : Hal.U32;
   begin
      --  --- Top_Status: three columns, each centered -----------------------------
      T := Tile (Top_Status);
      W3 := T.W / 3;

      StackH := TH2 + 4 + TH1;
      Y0 := CY (T.Y, T.H, StackH);
      TW := Gfx_Font.Text_Width ("14:37", 2);
      Gfx_Font.Draw_String (CX (T.X, W3, TW), Y0, "14:37", FC (Primary_Text), 2);
      TW := Gfx_Font.Text_Width ("GPS LOCK 12 SAT HDOP 0.8");
      Gfx_Font.Draw_String
        (CX (T.X, W3, TW), Y0 + TH2 + 4, "GPS LOCK 12 SAT HDOP 0.8", FC (Accent), 1);

      TW := Gfx_Font.Text_Width ("087 E");
      Gfx_Font.Draw_String (CX (T.X + W3, W3, TW), CY (T.Y, T.H, TH1), "087 E", FC (Accent), 1);

      RW_Right := T.W - 2 * W3;
      RX_Right := T.X + 2 * W3;
      StackH := TH1 + 4 + TH1 + 4 + TH1;
      Y0 := CY (T.Y, T.H, StackH);
      Gfx_Font.Draw_String
        (CX (RX_Right, RW_Right, Gfx_Font.Text_Width ("[ OBD-II OK ]")),
         Y0,
         "[ OBD-II OK ]",
         FC (Accent),
         1);
      Gfx_Font.Draw_String
        (CX (RX_Right, RW_Right, Gfx_Font.Text_Width ("[ CAN OK ]")),
         Y0 + TH1 + 4,
         "[ CAN OK ]",
         FC (Accent),
         1);
      Gfx_Font.Draw_String
        (CX (RX_Right, RW_Right, Gfx_Font.Text_Width ("[ AUDIO READY ]")),
         Y0 + 2 * (TH1 + 4),
         "[ AUDIO READY ]",
         FC (Accent),
         1);

      --  --- Left_Speed: speed + MPH centered upper; GPS block centered lower -----
      L := Tile (Left_Speed);
      Upper_H := L.H * 46 / 100;
      RowW :=
        Gfx_Font.Text_Width ("65", Speed_Scale) + 12 + Gfx_Font.Text_Width ("MPH");
      RowH_Spd := TH5;
      Y0 := L.Y + (Upper_H - RowH_Spd) / 2;
      TW := Gfx_Font.Text_Width ("65", Speed_Scale);
      TX0 := CX (L.X, L.W, RowW);
      Gfx_Font.Draw_String (TX0, Y0, "65", FC (Primary_Text), Speed_Scale);
      Gfx_Font.Draw_String
        (TX0 + TW + 12,
         Y0 + (TH5 - TH1) / 2,
         "MPH",
         FC (Accent),
         1);

      Lower_Y := L.Y + Upper_H;
      Lower_H := L.H - Upper_H;
      StackH := TH1 + 4 + TH1 + 4 + TH1;
      Y0 := Lower_Y + (Lower_H - StackH) / 2;
      TW := Gfx_Font.Text_Width ("LAT 30.2671 N");
      Gfx_Font.Draw_String (CX (L.X, L.W, TW), Y0, "LAT 30.2671 N", FC (Primary_Text), 1);
      TW := Gfx_Font.Text_Width ("LON 97.7430 W");
      Gfx_Font.Draw_String (CX (L.X, L.W, TW), Y0 + TH1 + 4, "LON 97.7430 W", FC (Primary_Text), 1);
      TW := Gfx_Font.Text_Width ("ALT 148 M");
      Gfx_Font.Draw_String (CX (L.X, L.W, TW), Y0 + 2 * (TH1 + 4), "ALT 148 M", FC (Primary_Text), 1);

      --  --- Right_Diagnostics title ----------------------------------------------
      R := Tile (Right_Diagnostics);
      IX := R.X + 4;
      IY := R.Y + 4;
      IW := R.W - 8;
      IH := Diag_Title_H - 4;
      TW := Gfx_Font.Text_Width ("DIAGNOSTICS");
      Gfx_Font.Draw_String (CX (IX, IW, TW), CY (IY, IH, TH1), "DIAGNOSTICS", FC (Accent), 1);

      --  --- Diagnostic rows: label + value centered as one line -------------------
      DR := Diag_Row (0);
      LW := Gfx_Font.Text_Width ("RPM");
      VW := Gfx_Font.Text_Width ("1,840");
      TW_Line := LW + GapLbl + VW;
      TX0 := DR.X + (DR.W - TW_Line) / 2;
      TY_Text := CY (DR.Y, DR.H * 40 / 100, TH1);
      Gfx_Font.Draw_String (TX0, TY_Text, "RPM", FC (Accent), 1);
      Gfx_Font.Draw_String (TX0 + LW + GapLbl, TY_Text, "1,840", FC (Primary_Text), 1);

      DR := Diag_Row (1);
      LW := Gfx_Font.Text_Width ("COOLANT");
      VW := Gfx_Font.Text_Width ("92 C");
      TW_Line := LW + GapLbl + VW;
      TX0 := DR.X + (DR.W - TW_Line) / 2;
      TY_Text := CY (DR.Y, DR.H * 40 / 100, TH1);
      Gfx_Font.Draw_String (TX0, TY_Text, "COOLANT", FC (Accent), 1);
      Gfx_Font.Draw_String (TX0 + LW + GapLbl, TY_Text, "92 C", FC (Primary_Text), 1);

      DR := Diag_Row (2);
      LW := Gfx_Font.Text_Width ("FUEL");
      VW := Gfx_Font.Text_Width ("60%");
      TW_Line := LW + GapLbl + VW;
      TX0 := DR.X + (DR.W - TW_Line) / 2;
      TY_Text := CY (DR.Y, DR.H * 40 / 100, TH1);
      Gfx_Font.Draw_String (TX0, TY_Text, "FUEL", FC (Accent), 1);
      Gfx_Font.Draw_String (TX0 + LW + GapLbl, TY_Text, "60%", FC (Primary_Text), 1);

      DR := Diag_Row (3);
      LW := Gfx_Font.Text_Width ("BATT");
      VW := Gfx_Font.Text_Width ("13.8 V");
      TW_Line := LW + GapLbl + VW;
      TX0 := DR.X + (DR.W - TW_Line) / 2;
      TY_Text := CY (DR.Y, DR.H * 40 / 100, TH1);
      Gfx_Font.Draw_String (TX0, TY_Text, "BATT", FC (Accent), 1);
      Gfx_Font.Draw_String (TX0 + LW + GapLbl, TY_Text, "13.8 V", FC (Primary_Text), 1);

      DR := Diag_Row (4);
      LW := Gfx_Font.Text_Width ("OIL PRES");
      VW := Gfx_Font.Text_Width ("47 PSI");
      TW_Line := LW + GapLbl + VW;
      TX0 := DR.X + (DR.W - TW_Line) / 2;
      TY_Text := CY (DR.Y, DR.H * 40 / 100, TH1);
      Gfx_Font.Draw_String (TX0, TY_Text, "OIL PRES", FC (Accent), 1);
      Gfx_Font.Draw_String (TX0 + LW + GapLbl, TY_Text, "47 PSI", FC (Primary_Text), 1);

      --  --- Bottom trip (above ruler ticks) ---------------------------------------
      B := Tile (Bottom_Trip);
      Text_Zone_H := B.H - 20;
      Trip_TW := Gfx_Font.Text_Width ("TRIP 247 KM - AVG 58 KM/H - T+ 04:12:33");
      Gfx_Font.Draw_String
        (CX (B.X, B.W, Trip_TW),
         B.Y + (Text_Zone_H - TH1) / 2,
         "TRIP 247 KM - AVG 58 KM/H - T+ 04:12:33",
         FC (Accent),
         1);
   end Draw_Mock_Text;

   procedure Draw_Home_Mockup is
      L : Region;
      R : Region;
      B : Region;
   begin
      Sync_Layout_From_FB;

      Hal.Display.Fill (C (Background));
      Subtle_Topo_Lines;

      for Id in Tile_Id loop
         declare
            T : constant Region := Tile (Id);
         begin
            Hal.Display.Fill_Rect (T.X + 1, T.Y + 1, T.W - 2, T.H - 2, C (Tile_Interior));
            Hal.Display.Frame_Rect (T.X, T.Y, T.W, T.H, C (Divider), 1);
            Hal.Display.Frame_Rect (T.X + 1, T.Y + 1, T.W - 2, T.H - 2, C (Accent), 1);
         end;
      end loop;

      L := Tile (Left_Speed);
      Draw_Brackets (L, 18, 2, Accent);

      R := Tile (Right_Diagnostics);
      Hal.Display.Fill_Rect (R.X + 4, R.Y + 4, R.W - 8, Diag_Title_H - 4, C (Alert_Tint));
      Hal.Display.Fill_Rect (R.X + 4, R.Y + Diag_Title_H - 2, R.W - 8, 1, C (Accent));

      Draw_Diag_Rows;

      B := Tile (Bottom_Trip);
      Bottom_Ruler (B);

      Draw_Mock_Text;

      Hal.Display.Flush;
   end Draw_Home_Mockup;

end Screen_Background;
