--  ui-pages-home.ads — Home page (clock + GPS speed + heading)

with Hal.Input;

package UI.Pages.Home is

   procedure Update;
   procedure Draw;
   procedure Handle_Event (E : Hal.Input.Event);

end UI.Pages.Home;
