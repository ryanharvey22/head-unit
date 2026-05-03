--  screen_background — Static home mockup chrome (design_concepts/head_unit_mockup_home.png).
--
--  Colors follow design_concepts/README.md palette; layout scales with Hal.Display Width×Height.
--  Attribution: CREDITS.md (UI palette / font).

with Hal;

package Screen_Background is

   type Tile_Id is (Top_Status, Left_Speed, Right_Diagnostics, Bottom_Trip);

   type Region is record
      X, Y, W, H : Hal.U32;
   end record;

   function Tile (Id : Tile_Id) return Region;

   subtype Diag_Row_Index is Natural range 0 .. 4;

   --  Row bands inside Right_Diagnostics (for future RPM / coolant / fuel / batt / oil).
   function Diag_Row (Row : Diag_Row_Index) return Region;

   --  Full layout: background, tile frames, corner brackets, diag dividers, gauge stubs.
   procedure Draw_Home_Mockup;

   --  --- Palette (XRGB) ---------------------------------------------------------

   Background     : constant Hal.U32 := 16#000A_0E13#;
   Topo_Overlay   : constant Hal.U32 := 16#0013_181F#;
   Primary_Text   : constant Hal.U32 := 16#00ED_E8DC#;
   Accent         : constant Hal.U32 := 16#00C9_A961#;
   Status_OK      : constant Hal.U32 := 16#007B_8B5C#;
   Divider        : constant Hal.U32 := 16#001F_2630#;
   Alert_Warning  : constant Hal.U32 := 16#00D0_4545#;
   Alert_Critical : constant Hal.U32 := 16#00FF_6B5A#;
   Alert_Tint     : constant Hal.U32 := 16#0015_080A#;
   Tile_Interior  : constant Hal.U32 := 16#000C_1018#;

   Boot_Fill : constant Hal.U32 := Background;

end Screen_Background;
