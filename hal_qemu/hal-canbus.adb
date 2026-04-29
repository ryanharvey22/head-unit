--  hal-canbus.adb (Pi) — STUB
--
--  TODO: SPI driver for MCP2515 standalone CAN controller.
--  Configure bitrate, enable interrupts, drain RX FIFO into Receive() queue.

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
