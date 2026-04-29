--  hal-input.adb (Pi) — STUB
--
--  TODO: real implementation will poll GPIO inputs for rotary encoder
--  (quadrature decode) and a push-button.  For now, returns no events.

package body Hal.Input is

   procedure Init is
   begin
      null;
   end Init;

   procedure Poll is
   begin
      null;
   end Poll;

   function Get_Next_Event return Event is
      E : Event;
   begin
      return E;  --  Kind defaults to None
   end Get_Next_Event;

end Hal.Input;
