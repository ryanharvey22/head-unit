--  hal-clock.ads — Microsecond timer abstraction
--
--  All implementations expose a 1 MHz monotonic counter:
--    Pi/QEMU:  BCM2711 system timer at 0xFE003004
--    Sim:      clock_gettime(CLOCK_MONOTONIC) scaled to microseconds

with Hal; use Hal;

package Hal.Clock is

   --  Get the current time in microseconds.
   --  Wraps every ~71 minutes, so use modular subtraction for deltas.
   function Now_Us return U32;

   --  Busy-wait for at least Us microseconds.
   procedure Wait_Us (Us : U32);

   --  Convenience: wait for milliseconds.
   procedure Wait_Ms (Ms : U32);

end Hal.Clock;
