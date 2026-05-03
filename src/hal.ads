--  hal.ads — Hardware Abstraction Layer root package
--
--  Common scalar types used across all HAL child packages.

with Interfaces; use Interfaces;

package Hal is

   pragma Pure;

   subtype U8  is Unsigned_8;
   subtype U16 is Unsigned_16;
   subtype U32 is Unsigned_32;
   subtype U64 is Unsigned_64;

   subtype I16 is Integer_16;
   subtype I32 is Integer_32;
   subtype I64 is Integer_64;

end Hal;
