--  fft.ads — Radix-2 Decimation-in-Time FFT
--
--  Fixed-point (Q15) in-place FFT using the Cooley-Tukey algorithm.
--  Operates on arrays of complex Q15 samples.
--
--  Usage:
--    1. Fill an array of Complex_Q15 with your input signal
--    2. Call FFT_Forward to transform to frequency domain
--    3. Each bin k represents frequency k * (sample_rate / N)
--
--  N must be a power of 2.  Max supported: 1024 points.

with Fixed_Point; use Fixed_Point;

package FFT is

   Max_N : constant := 1024;

   type Complex_Q15 is record
      Re : Q15;
      Im : Q15;
   end record;

   type Complex_Array is array (Natural range <>) of Complex_Q15;

   --  In-place forward FFT.  Input/output in Buf(0 .. N-1).
   --  N must be a power of 2, N <= Max_N.
   procedure Forward (Buf : in out Complex_Array; N : Positive);

   --  Compute magnitude squared of each bin: Re^2 + Im^2
   --  Result in Mag(0 .. N-1) as Unsigned_32 (no overflow from Q15^2)
   type Magnitude_Array is array (Natural range <>) of Interfaces.Unsigned_32;
   procedure Magnitude_Sq (Buf : Complex_Array;
                           Mag : out Magnitude_Array;
                           N   : Positive);

end FFT;
