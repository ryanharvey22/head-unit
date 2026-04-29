--  hal-canbus.adb (Pi) — vehicle bus driver shim
--
--  Despite the name, this driver covers BOTH:
--    * CAN bus (ISO 15765) — for 2008+ vehicles, via MCP2515 over SPI
--    * K-line (ISO 9141-2) — for the 1996-97 LX 450, via L9637D over UART
--
--  The Hal.CANBus interface is generic enough to carry OBD-II frames from
--  either physical layer.  Application code deals only in Frame records
--  and the standard SAE J1979 PIDs (decoded by the Obd2 package).
--
--  Build_Request and Decode for OBD-II PIDs live in obd2/, not here.
--  This driver only moves bytes.
--
--  TODO (LX 450 K-line — your current vehicle):
--    1. In Init: drive K-line low for 200ms (5-baud wakeup), high for 200ms,
--       then set UART to 10.4 kbaud.  Read sync byte 0x55 and key bytes.
--    2. Build a request frame manually for OBD-II:
--         [0x68, 0x6A, 0xF1, mode_byte, pid_byte, checksum]
--       Send it over the UART, wait for response.
--    3. Map the response bytes into a Frame for return via Receive.
--
--  TODO (future CAN car — when you upgrade):
--    1. Replace this body with an MCP2515 SPI driver.
--    2. Hal.CANBus spec stays the same — application code untouched.
--
--  TODO (frame size):
--    The current Frame_Data is 8 bytes (CAN payload limit).  K-line
--    responses can be longer.  If we hit that limitation, expand
--    Frame_Data to 12 bytes — OBD-II responses fit comfortably in 12.

package body Hal.CANBus is

   procedure Init (Bitrate_Kbps : U32 := 500) is
      pragma Unreferenced (Bitrate_Kbps);
   begin
      null;
   end Init;

   procedure Poll is
   begin
      null;
   end Poll;

   function Receive (F : out Frame) return Boolean is
   begin
      F := (Id => 0, Length => 0, Extended => False, Data => (others => 0));
      return False;
   end Receive;

   procedure Send (F : Frame) is
      pragma Unreferenced (F);
   begin
      null;
   end Send;

end Hal.CANBus;
