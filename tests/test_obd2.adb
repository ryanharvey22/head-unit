--  test_obd2.adb — Native unit test for the OBD-II decoder
--
--  Compile and run on host:
--    gnatmake-12 -aIobd2 -aItests -gnata test_obd2.adb
--    ./test_obd2
--
--  Or use the Makefile:
--    make test

with Ada.Text_IO; use Ada.Text_IO;
with Interfaces;   use Interfaces;
with Obd2;
with Obd2.Decoder;

procedure Test_Obd2 is
   R : Obd2.Reading;
begin
   ------------------------------------------------------------------
   Put_Line ("test_obd2: Engine RPM at 1000 rpm");
   --  RPM = (A*256 + B) / 4 = (0x0F * 256 + 0xA0) / 4 = 4000 / 4 = 1000
   R := Obd2.Decoder.Decode (Obd2.Engine_Rpm, 16#0F#, 16#A0#, 0, 0);
   pragma Assert (R.Valid);
   pragma Assert (R.Pid_Code = 16#0C#);
   pragma Assert (R.Value = 1000);
   Put_Line ("  PASS");

   ------------------------------------------------------------------
   Put_Line ("test_obd2: Vehicle speed = 65 km/h");
   R := Obd2.Decoder.Decode (Obd2.Vehicle_Speed, 65, 0, 0, 0);
   pragma Assert (R.Valid);
   pragma Assert (R.Value = 65);
   Put_Line ("  PASS");

   ------------------------------------------------------------------
   Put_Line ("test_obd2: Coolant temp = 50 C (raw 90)");
   R := Obd2.Decoder.Decode (Obd2.Coolant_Temp, 90, 0, 0, 0);
   pragma Assert (R.Valid);
   pragma Assert (R.Value = 50);
   Put_Line ("  PASS");

   ------------------------------------------------------------------
   Put_Line ("test_obd2: Throttle 50 percent (raw 128)");
   R := Obd2.Decoder.Decode (Obd2.Throttle_Position, 128, 0, 0, 0);
   pragma Assert (R.Valid);
   --  128 * 100 / 255 = 50 (integer truncation)
   pragma Assert (R.Value = 50);
   Put_Line ("  PASS");

   ------------------------------------------------------------------
   Put_Line ("test_obd2: Build_Request emits mode 0x01 + PID byte");
   declare
      Mode_B, Pid_B : Obd2.U8;
   begin
      Obd2.Decoder.Build_Request (Obd2.Engine_Rpm, Mode_B, Pid_B);
      pragma Assert (Mode_B = 16#01#);
      pragma Assert (Pid_B = 16#0C#);

      Obd2.Decoder.Build_Request (Obd2.Vehicle_Speed, Mode_B, Pid_B);
      pragma Assert (Pid_B = 16#0D#);
   end;
   Put_Line ("  PASS");

   ------------------------------------------------------------------
   New_Line;
   Put_Line ("test_obd2: ALL PASS");
end Test_Obd2;
