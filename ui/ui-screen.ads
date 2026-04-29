--  ui-screen.ads — Page management
--
--  The head unit has multiple "pages" (Home, OBD, Audio, etc.).
--  The Screen package tracks which page is active and dispatches
--  Update/Draw to it.

with Hal.Input;

package UI.Screen is

   type Page_Id is (Home, OBD, Audio);

   procedure Init;

   --  Tell the screen one frame's worth of time has passed.
   --  Forwards to the active page's Update.
   procedure Update;

   --  Render the active page.  Calls Hal.Display ops then Flush.
   procedure Draw;

   --  Forward an input event to the active page.
   --  Some events (like Quit) are handled at this layer.
   procedure Handle_Event (E : Hal.Input.Event);

   --  Has the user requested to quit?  (Sim only really uses this.)
   function Should_Quit return Boolean;

end UI.Screen;
