--  obd2.ads — OBD-II protocol types
--
--  Pure-logic package: decodes SAE J1979 OBD-II PID responses.
--  Independent of physical layer (CAN ISO 15765 or K-line ISO 9141-2).
--  Testable natively on a laptop.
--
--  Reference: SAE J1979 (OBD-II PIDs), Wikipedia "OBD-II PIDs" has the
--  scaling formulas for every standard PID in human-readable form.

with Interfaces;

package Obd2 is

   pragma Pure;

   subtype U8  is Interfaces.Unsigned_8;
   subtype U16 is Interfaces.Unsigned_16;
   subtype U32 is Interfaces.Unsigned_32;
   subtype I32 is Interfaces.Integer_32;

   --  Subset of mode 0x01 PIDs that we'll show on the head unit.
   --  Add more here (engine load, intake air, MAF, fuel trim, etc.)
   --  and a corresponding case in obd2-decoder.adb.
   --  Enum literals are listed in PID-byte order so the representation
   --  clause below is monotonically increasing (Ada requirement).
   type Pid is
      (Engine_Load,            --  0x04, %
       Coolant_Temp,           --  0x05, °C
       Engine_Rpm,             --  0x0C, rpm
       Vehicle_Speed,          --  0x0D, km/h
       Intake_Air_Temp,        --  0x0F, °C
       Maf_Rate,               --  0x10, g/s
       Throttle_Position,      --  0x11, %
       Fuel_Level);            --  0x2F, %

   --  PID byte values per SAE J1979 mode 0x01.
   for Pid use
      (Engine_Load       => 16#04#,
       Coolant_Temp      => 16#05#,
       Engine_Rpm        => 16#0C#,
       Vehicle_Speed     => 16#0D#,
       Intake_Air_Temp   => 16#0F#,
       Maf_Rate          => 16#10#,
       Throttle_Position => 16#11#,
       Fuel_Level        => 16#2F#);

   for Pid'Size use 8;

   --  Decoded reading.  Value scaled to integer units (see comments
   --  on the Pid enum above).  Some PIDs use scaled-x100 to keep a
   --  decimal place without floats — call out which in the body.
   type Reading is record
      Valid    : Boolean := False;
      Pid_Code : U8 := 0;
      Value    : I32 := 0;
   end record;

end Obd2;
