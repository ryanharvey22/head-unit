--  hal-gps.ads — GPS receiver abstraction
--
--  Pi:   reads NMEA sentences from PL011 UART (or USB-serial)
--  Sim:  replays data/sample.nmea, or accepts injected fixes via Fake_Data

with Hal; use Hal;

package Hal.GPS is

   type Fix is record
      Valid     : Boolean := False;
      Latitude  : I32 := 0;          --  scaled by 1e6 (decimal degrees * 1_000_000)
      Longitude : I32 := 0;          --  scaled by 1e6
      Speed_Cms : U32 := 0;          --  centimetres per second
      Heading   : U16 := 0;          --  degrees * 100 (0..35999)
   end record;

   procedure Init;

   --  Pull any available NMEA bytes from the source and update the fix.
   --  Call once per frame.
   procedure Poll;

   --  Get the latest known fix.  Valid is False until first lock.
   function Current_Fix return Fix;

end Hal.GPS;
