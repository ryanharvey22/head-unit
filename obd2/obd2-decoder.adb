--  obd2-decoder.adb — SAE J1979 mode 0x01 PID scaling
--
--  Implemented:
--    Engine_Rpm         (A*256 + B) / 4
--    Vehicle_Speed      A
--    Coolant_Temp       A - 40
--    Throttle_Position  A * 100 / 255
--    Fuel_Level         A * 100 / 255
--    Intake_Air_Temp    A - 40
--    Engine_Load        A * 100 / 255
--    Maf_Rate           (A*256 + B) (in g/s * 100, hence Value*100 = grams/sec)
--
--  TODO: add more PIDs (ambient temp 0x46, control module voltage 0x42,
--  oxygen sensors 0x14..0x1B, fuel pressure 0x0A, etc.) as you need them.

with Interfaces; use Interfaces;

package body Obd2.Decoder is

   function Decode (P : Pid; A, B, C, D : U8) return Reading is
      pragma Unreferenced (C, D);
      R : Reading;
   begin
      R.Pid_Code := Pid'Enum_Rep (P);
      R.Valid    := True;

      case P is
         when Engine_Rpm =>
            R.Value := I32 (Shift_Left (U16 (A), 8) or U16 (B)) / 4;

         when Vehicle_Speed =>
            R.Value := I32 (A);

         when Coolant_Temp | Intake_Air_Temp =>
            R.Value := I32 (A) - 40;

         when Throttle_Position | Fuel_Level | Engine_Load =>
            R.Value := (I32 (A) * 100) / 255;

         when Maf_Rate =>
            R.Value := I32 (Shift_Left (U16 (A), 8) or U16 (B));
      end case;

      return R;
   end Decode;

   procedure Build_Request (P : Pid; Mode_Byte : out U8; Pid_Byte : out U8) is
   begin
      Mode_Byte := 16#01#;
      Pid_Byte  := Pid'Enum_Rep (P);
   end Build_Request;

end Obd2.Decoder;
