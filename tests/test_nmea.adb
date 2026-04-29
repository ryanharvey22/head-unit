--  test_nmea.adb — Native unit test for the NMEA parser
--
--  Compile and run on host:
--    gnatmake-12 -aInmea -aItests -gnata test_nmea.adb
--    ./test_nmea
--
--  Or use the Makefile:
--    make test

with Ada.Text_IO; use Ada.Text_IO;
with Interfaces;   use Interfaces;
with Nmea;
with Nmea.Parser;

procedure Test_Nmea is

   procedure Feed_String (S : String) is
   begin
      for C of S loop
         Nmea.Parser.Feed (Character'Pos (C));
      end loop;
   end Feed_String;

   --  A complete real-world $GPGGA sentence (Wikipedia example).
   --  Checksum 0x47 is correct for this body.
   Sample_GGA : constant String :=
      "$GPGGA,123519,4807.038,N,01131.000,E,1,08,0.9,545.4,M,46.9,M,,*47"
      & ASCII.CR & ASCII.LF;

   --  Same sentence with a deliberately wrong checksum (0x48 vs 0x47).
   Bad_Csum_GGA : constant String :=
      "$GPGGA,123519,4807.038,N,01131.000,E,1,08,0.9,545.4,M,46.9,M,,*48"
      & ASCII.CR & ASCII.LF;

   --  Garbage bytes followed by a real sentence — parser should resync.
   Garbled : constant String :=
      "junk junk $$$" & Sample_GGA;

begin
   ------------------------------------------------------------------
   Put_Line ("test_nmea: starts in clean state");
   Nmea.Parser.Reset;
   pragma Assert (not Nmea.Parser.Has_New_Fix);
   pragma Assert (Nmea.Parser.Sentences_Accepted = 0);
   pragma Assert (Nmea.Parser.Sentences_Rejected = 0);
   Put_Line ("  PASS");

   ------------------------------------------------------------------
   Put_Line ("test_nmea: valid GGA sentence is accepted");
   Nmea.Parser.Reset;
   Feed_String (Sample_GGA);
   pragma Assert (Nmea.Parser.Sentences_Accepted = 1);
   pragma Assert (Nmea.Parser.Sentences_Rejected = 0);
   Put_Line ("  PASS");

   ------------------------------------------------------------------
   Put_Line ("test_nmea: bad checksum is rejected");
   Nmea.Parser.Reset;
   Feed_String (Bad_Csum_GGA);
   pragma Assert (Nmea.Parser.Sentences_Accepted = 0);
   pragma Assert (Nmea.Parser.Sentences_Rejected = 1);
   Put_Line ("  PASS");

   ------------------------------------------------------------------
   Put_Line ("test_nmea: parser resyncs after garbage");
   Nmea.Parser.Reset;
   Feed_String (Garbled);
   pragma Assert (Nmea.Parser.Sentences_Accepted = 1);
   Put_Line ("  PASS");

   ------------------------------------------------------------------
   --  TODO: once Parse_GGA is implemented in nmea-parser.adb,
   --  uncomment to verify lat/lon extraction.
   --
   --  Put_Line ("test_nmea: GGA fix lat/lon extraction");
   --  Nmea.Parser.Reset;
   --  Feed_String (Sample_GGA);
   --  pragma Assert (Nmea.Parser.Has_New_Fix);
   --  declare
   --     F : constant Nmea.Fix_Type := Nmea.Parser.Get_Fix;
   --  begin
   --     pragma Assert (F.Has_Fix);
   --     --  4807.038 N -> 48 + 7.038/60 = 48.117300 -> 48_117_300 in 1e-6 deg
   --     pragma Assert (abs (F.Lat_E6 - 48_117_300) < 100);
   --     --  01131.000 E -> 11.516667 -> 11_516_667
   --     pragma Assert (abs (F.Lon_E6 - 11_516_667) < 100);
   --     pragma Assert (F.Sats = 8);
   --  end;
   --  Put_Line ("  PASS");
   ------------------------------------------------------------------

   New_Line;
   Put_Line ("test_nmea: ALL PASS");
end Test_Nmea;
