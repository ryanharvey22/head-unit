--  obd2-decoder.ads — Decode OBD-II mode 0x01 PID responses
--
--  Usage:
--    R := Obd2.Decoder.Decode (Obd2.Engine_Rpm, A => 16#0F#, B => 16#A0#,
--                              C => 0, D => 0);
--    --  R.Value = 1000  (RPM = (A*256 + B) / 4)
--
--  The four data bytes A/B/C/D are the payload bytes that follow the
--  mode echo (0x41) and PID byte in a J1979 response frame.  Most PIDs
--  use only A or A+B; pass 0 for unused bytes.

package Obd2.Decoder is

   --  Decode a response payload into a scaled reading.
   --  Returns Valid=False if the PID is not yet implemented.
   function Decode (P : Pid; A, B, C, D : U8) return Reading;

   --  Build a request payload for a PID (mode 0x01).
   --  The transport-specific framing (CAN headers, K-line addressing)
   --  is the driver's responsibility — this just returns the two bytes
   --  that go in the data section: [mode, pid].
   procedure Build_Request (P : Pid; Mode_Byte : out U8; Pid_Byte : out U8);

end Obd2.Decoder;
