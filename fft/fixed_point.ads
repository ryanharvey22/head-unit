--  fixed_point.ads — Q15 fixed-point arithmetic
--
--  Q15 format: 1 sign bit + 15 fractional bits
--  Range: -1.0 to +0.999969  (stored as -32768 to +32767)
--  Resolution: 1/32768 ≈ 0.0000305
--
--  This is the standard format used in real radar/DSP systems because:
--  - Integer ALU is faster and deterministic (no floating-point surprises)
--  - Maps directly to 16-bit hardware multipliers
--  - Overflow behavior is predictable and controllable

with Interfaces; use Interfaces;

package Fixed_Point is

   subtype Q15 is Integer_16;

   --  Convert a Q15 to its approximate floating-point value (for debug output)
   --  Returns the integer part * 1000 (milli-units) to avoid needing float
   function To_Milli (X : Q15) return Integer_32;

   --  Saturating Q15 multiply: (a * b) >> 15, clamped to Q15 range
   function Mul (A, B : Q15) return Q15;

   --  Saturating add
   function Add_Sat (A, B : Q15) return Q15;

   --  Saturating subtract
   function Sub_Sat (A, B : Q15) return Q15;

end Fixed_Point;
