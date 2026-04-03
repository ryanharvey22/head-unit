--  sin_table.ads — Precomputed sine lookup table in Q15
--
--  Contains sin(2*pi*k/1024) for k = 0..255 (first quadrant).
--  Cosine and other quadrants derived by symmetry.
--
--  TODO: generate this table.  Each entry is:
--    Q15(round(sin(2*pi*k/1024) * 32767))
--
--  Example entries:
--    k=0:   sin(0)        =  0      → Q15:  0
--    k=64:  sin(pi/8)     =  0.3827 → Q15:  12540
--    k=128: sin(pi/4)     =  0.7071 → Q15:  23170
--    k=192: sin(3*pi/8)   =  0.9239 → Q15:  30274
--    k=256: sin(pi/2)     =  1.0    → Q15:  32767

with Fixed_Point; use Fixed_Point;

package Sin_Table is

   Table_Size : constant := 256;

   Table : constant array (0 .. Table_Size) of Q15;
   --  TODO: fill in the 257 values (0..256 inclusive for interpolation)
   pragma Import (Ada, Table);

   --  Look up sin(2*pi*k/N) in Q15, using symmetry for all four quadrants
   function Sin_Q15 (K : Natural; N : Positive) return Q15;

   --  Look up cos(2*pi*k/N) in Q15 = sin(2*pi*k/N + pi/2)
   function Cos_Q15 (K : Natural; N : Positive) return Q15;

end Sin_Table;
