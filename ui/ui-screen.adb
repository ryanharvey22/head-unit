--  ui-screen.adb — Page manager implementation

with Hal.Input; use type Hal.Input.Event_Kind;
with UI.Pages.Home;

package body UI.Screen is

   Active_Page : Page_Id := Home;
   Quit_Requested : Boolean := False;

   procedure Init is
   begin
      Active_Page := Home;
      Quit_Requested := False;
   end Init;

   procedure Update is
   begin
      case Active_Page is
         when Home  => UI.Pages.Home.Update;
         when OBD   => null;     --  TODO
         when Audio => null;     --  TODO
      end case;
   end Update;

   procedure Draw is
   begin
      case Active_Page is
         when Home  => UI.Pages.Home.Draw;
         when OBD   => null;
         when Audio => null;
      end case;
   end Draw;

   procedure Handle_Event (E : Hal.Input.Event) is
   begin
      if E.Kind = Hal.Input.Quit then
         Quit_Requested := True;
         return;
      end if;

      case Active_Page is
         when Home  => UI.Pages.Home.Handle_Event (E);
         when OBD   => null;
         when Audio => null;
      end case;
   end Handle_Event;

   function Should_Quit return Boolean is
   begin
      return Quit_Requested;
   end Should_Quit;

end UI.Screen;
