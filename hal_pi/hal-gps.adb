--  hal-gps.adb (Pi) — GPS driver shim
--
--  Connects the abstract Hal.GPS interface to the pure Nmea.Parser logic.
--  This file should stay small.  All NMEA parsing complexity lives in nmea/
--  where it is unit-testable on a host machine.
--
--  TODO (driver-side, hardware only — only meaningful on a real Pi):
--    1. In Init: configure PL011 UART0 on alt pins (or use USB-serial),
--       set 9600 baud, 8N1, enable RX.
--    2. In Poll: drain available bytes from the UART RX FIFO and feed
--       each byte to Nmea.Parser.Feed.  Then, if Has_New_Fix, copy the
--       parsed Fix_Type into Latest with the field-name translation.
--
--  See: nmea/ for parser internals, hal/hal-gps.ads for the contract.

with Nmea;
with Nmea.Parser;

package body Hal.GPS is

   Latest : Fix;

   procedure Init is
   begin
      Nmea.Parser.Reset;
      Latest := (Valid => False, others => <>);
      --  TODO: configure PL011 UART0 here.
   end Init;

   procedure Poll is
   begin
      --  TODO: while UART has bytes, read byte B and call:
      --     Nmea.Parser.Feed (B);
      --
      --  Once Nmea.Parser implements GGA/RMC parsing, replace this
      --  with the fix-pull below:
      --
      --  if Nmea.Parser.Has_New_Fix then
      --     declare
      --        F : constant Nmea.Fix_Type := Nmea.Parser.Get_Fix;
      --     begin
      --        Latest := (Valid     => F.Has_Fix,
      --                   Latitude  => F.Lat_E6,
      --                   Longitude => F.Lon_E6,
      --                   Speed_Cms => F.Speed_Cm_S,
      --                   Heading   => F.Heading_Cdeg);
      --     end;
      --  end if;
      null;
   end Poll;

   function Current_Fix return Fix is
   begin
      return Latest;
   end Current_Fix;

end Hal.GPS;
