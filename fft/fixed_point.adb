--  fixed_point.adb — Q15 fixed-point arithmetic implementation

package body Fixed_Point is

   function To_Milli (X : Q15) return Integer_32 is
   begin
      return (Integer_32 (X) * 1000) / 32768;
   end To_Milli;

   function Mul (A, B : Q15) return Q15 is
      Full : constant Integer_32 := Integer_32 (A) * Integer_32 (B);
      Result : Integer_32;
   begin
      Result := Full / 32768;
      if Result > 32767 then
         return 32767;
      elsif Result < -32768 then
         return -32768;
      else
         return Q15 (Result);
      end if;
   end Mul;

   function Add_Sat (A, B : Q15) return Q15 is
      Sum : constant Integer_32 := Integer_32 (A) + Integer_32 (B);
   begin
      if Sum > 32767 then
         return 32767;
      elsif Sum < -32768 then
         return -32768;
      else
         return Q15 (Sum);
      end if;
   end Add_Sat;

   function Sub_Sat (A, B : Q15) return Q15 is
      Diff : constant Integer_32 := Integer_32 (A) - Integer_32 (B);
   begin
      if Diff > 32767 then
         return 32767;
      elsif Diff < -32768 then
         return -32768;
      else
         return Q15 (Diff);
      end if;
   end Sub_Sat;

end Fixed_Point;
