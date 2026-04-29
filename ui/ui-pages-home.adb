--  ui-pages-home.adb — Home page implementation

with Interfaces; use Interfaces;
with Hal; use Hal;
with Hal.Display;
with Hal.GPS;
with Hal.Clock;
with UI.Theme;
with UI.Widgets;

package body UI.Pages.Home is

   --  Cached values updated by Update, drawn by Draw
   Last_Frame_Us : U32 := 0;
   Frame_Counter : U32 := 0;
   Anim_X        : U32 := 0;

   procedure Update is
      Now : constant U32 := Hal.Clock.Now_Us;
   begin
      Frame_Counter := Frame_Counter + 1;
      Last_Frame_Us := Now;
      Anim_X := (Frame_Counter * 4) mod (Hal.Display.Width - 80);
   end Update;

   procedure Draw is
      Fix : constant Hal.GPS.Fix := Hal.GPS.Current_Fix;
      Speed_Kph : constant I32 :=
         I32 ((Integer_64 (Fix.Speed_Cms) * 36) / 1000);
   begin
      Hal.Display.Fill (UI.Theme.BG_Primary);

      --  Title bar
      Hal.Display.Fill_Rect
         (0, 0, Hal.Display.Width, 40, UI.Theme.Accent);
      UI.Widgets.Put_Text (16, 12, "HEAD UNIT", UI.Theme.FG_Primary);
      UI.Widgets.Put_Text
         (Hal.Display.Width - 192, 12, "BARE METAL ADA",
          UI.Theme.FG_Primary);

      --  Speed panel
      Hal.Display.Fill_Rect (40, 80, 280, 160, UI.Theme.BG_Panel);
      UI.Widgets.Put_Text (60, 96, "SPEED", UI.Theme.FG_Secondary);
      UI.Widgets.Put_Number
         (60, 130, Speed_Kph, 4, UI.Theme.FG_Primary);
      UI.Widgets.Put_Text (60, 200, "KPH", UI.Theme.FG_Secondary);

      --  Heading panel
      Hal.Display.Fill_Rect (340, 80, 260, 160, UI.Theme.BG_Panel);
      UI.Widgets.Put_Text (360, 96, "HEADING", UI.Theme.FG_Secondary);
      UI.Widgets.Put_Number
         (360, 130, I32 (Fix.Heading) / 100, 3, UI.Theme.FG_Primary);
      UI.Widgets.Put_Text (360, 200, "DEG", UI.Theme.FG_Secondary);

      --  Status line
      UI.Widgets.Put_Text (40, 280, "STATUS  RUNNING", UI.Theme.Success);
      UI.Widgets.Put_Text (40, 310, "GPS     ", UI.Theme.FG_Secondary);
      if Fix.Valid then
         UI.Widgets.Put_Text (40 + 8 * 8, 310, "LOCK", UI.Theme.Success);
      else
         UI.Widgets.Put_Text (40 + 8 * 8, 310, "NO FIX", UI.Theme.Warning);
      end if;

      UI.Widgets.Put_Text (40, 340, "FRAME   ", UI.Theme.FG_Secondary);
      UI.Widgets.Put_Number
         (40 + 8 * 8, 340, I32 (Frame_Counter), 8, UI.Theme.FG_Primary);

      --  Animated bar to prove the loop is running
      Hal.Display.Fill_Rect
         (0, 420, Hal.Display.Width, 20, UI.Theme.BG_Primary);
      Hal.Display.Fill_Rect (Anim_X, 420, 80, 20, UI.Theme.Warning);

      Hal.Display.Flush;
   end Draw;

   procedure Handle_Event (E : Hal.Input.Event) is
      pragma Unreferenced (E);
   begin
      null;  --  TODO: rotary encoder navigates between sub-views
   end Handle_Event;

end UI.Pages.Home;
