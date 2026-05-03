--  screen_background.ads — What we paint before real UI (v1 palette)
--
--  Hex colors match design_concepts/README.md “Color palette”.  Values are
--  XRGB (`16#00RRGGBB#`); pass to Hal.Display as Hal.Display.Color (...).

with Hal; use Hal;

package Screen_Background is

   pragma Pure;

   --  Base canvas
   Background   : constant U32 := 16#000A_0E13#;   --  #0A0E13
   Topo_Overlay : constant U32 := 16#0013_181F#;   --  #13181F contour layer

   --  Typography / chrome (for future text and chrome drawing)
   Primary_Text : constant U32 := 16#00ED_E8DC#;   --  #EDE8DC
   Accent       : constant U32 := 16#00C9_A961#;   --  #C9A961
   Status_OK    : constant U32 := 16#007B_8B5C#;   --  #7B8B5C
   Divider      : constant U32 := 16#001F_2630#;   --  #1F2630

   --  Alerts
   Alert_Warning  : constant U32 := 16#00D0_4545#;   --  #D04545
   Alert_Critical : constant U32 := 16#00FF_6B5A#;   --  #FF6B5A
   Alert_Tint     : constant U32 := 16#0015_080A#;   --  #15080A

   --  Full-screen fill used right after display init until pages draw regions.
   Boot_Fill : constant U32 := Background;

end Screen_Background;
