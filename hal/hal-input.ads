--  hal-input.ads — Rotary encoder + button input abstraction
--
--  Pi:   GPIO inputs polled, quadrature decoded
--  Sim:  SDL2 keyboard (Up/Down arrows = rotary, Enter = button)

with Hal; use Hal;

package Hal.Input is

   type Event_Kind is (None, Rotary_CW, Rotary_CCW, Button_Press, Button_Release, Quit);

   type Event is record
      Kind : Event_Kind := None;
   end record;

   procedure Init;

   --  Drain any pending hardware events.  Must be called each frame.
   procedure Poll;

   --  Pop the next pending event (None if queue is empty).
   --  Multiple events per frame are possible (e.g. fast rotary spin).
   function Get_Next_Event return Event;

end Hal.Input;
