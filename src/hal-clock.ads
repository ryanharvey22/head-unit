--  hal-clock.ads — Microsecond timer (Pi: CNTFRQ_EL0 / CNTPCT_EL0; CLO fallback)

with Hal; use Hal;

package Hal.Clock is

   --  Get the current time in microseconds.
   --  Wraps every ~71 minutes, so use modular subtraction for deltas.
   function Now_Us return U32;

   --  Busy-wait for at least Us microseconds.
   procedure Wait_Us (Us : U32);

   --  Convenience: wait for milliseconds.
   procedure Wait_Ms (Ms : U32);

   --  Busy wait using NOPs only — does not use CNTPCT/CLO (bring-up if Wait_* stalls).
   procedure Busy_Wait_Loops (Iterations : Natural);

end Hal.Clock;
