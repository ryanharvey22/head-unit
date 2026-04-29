--  nmea.ads — NMEA 0183 protocol types
--
--  Pure-logic package: parses NMEA sentences from a GPS receiver.
--  No HAL dependency, no MMIO, no I/O — testable natively on a laptop.
--
--  See: NMEA 0183 standard, common sentence types: GGA, RMC, GSA, VTG.

with Interfaces;

package Nmea is

   pragma Pure;

   subtype U8  is Interfaces.Unsigned_8;
   subtype U16 is Interfaces.Unsigned_16;
   subtype U32 is Interfaces.Unsigned_32;
   subtype I32 is Interfaces.Integer_32;

   --  Position fix.  All numeric fields are integers to avoid floats
   --  on bare metal (no FPU surprises, no soft-float runtime needed).
   type Fix_Type is record
      Has_Fix      : Boolean := False;
      Lat_E6       : I32 := 0;       --  latitude  in 1e-6 degrees, +N/-S
      Lon_E6       : I32 := 0;       --  longitude in 1e-6 degrees, +E/-W
      Speed_Cm_S   : U32 := 0;       --  ground speed in cm/s
      Heading_Cdeg : U16 := 0;       --  course over ground in 1/100 degree (0..35999)
      Sats         : U8  := 0;       --  satellites in use
      Hdop_X10     : U16 := 0;       --  horizontal DOP * 10
   end record;

end Nmea;
