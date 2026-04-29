--  nmea-parser.ads — Streaming NMEA 0183 sentence parser
--
--  Usage:
--    Nmea.Parser.Reset;
--    loop
--       Read one byte from the GPS UART;
--       Nmea.Parser.Feed (B);
--    end loop;
--    if Nmea.Parser.Has_New_Fix then
--       Use Nmea.Parser.Get_Fix;
--    end if;
--
--  The parser is a state machine that scans for "$...*XX\r\n" frames,
--  validates the XOR checksum, and (TODO) decodes the payload into
--  Fix_Type fields.
--
--  This package holds global state — there is one GPS receiver in this
--  system.  Not task-safe.

package Nmea.Parser is

   --  Reset the state machine.  Call once at startup.
   procedure Reset;

   --  Feed one byte from the GPS receiver.
   --  Buffers internally until end-of-sentence, then validates and parses.
   procedure Feed (B : U8);

   --  True if a fix has been parsed since the last call to Get_Fix.
   function Has_New_Fix return Boolean;

   --  Return the most recent fix.  Resets Has_New_Fix to False.
   function Get_Fix return Fix_Type;

   --  Diagnostic counters (useful for tests and UART debug output).
   function Sentences_Accepted return U32;
   function Sentences_Rejected return U32;

end Nmea.Parser;
