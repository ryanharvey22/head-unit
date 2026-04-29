--  hal-gps.adb (Pi) — STUB
--
--  TODO: read NMEA sentences from PL011 UART (or USB-serial),
--  parse with peripherals.gps_parser, update Latest_Fix.

package body Hal.GPS is

   Latest : Fix;

   procedure Init is
   begin
      Latest := (Valid => False, others => <>);
   end Init;

   procedure Poll is
   begin
      null;
   end Poll;

   function Current_Fix return Fix is
   begin
      return Latest;
   end Current_Fix;

end Hal.GPS;
