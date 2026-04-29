--  hal-canbus.ads — CAN bus abstraction (MCP2515 over SPI on real Pi)
--
--  Pi:   SPI driver talking to MCP2515 standalone CAN controller
--  Sim:  replays data/sample-can.log, or accepts Inject_Frame

with Hal; use Hal;

package Hal.CANBus is

   type Frame_Data is array (0 .. 7) of U8;

   type Frame is record
      Id       : U32 := 0;
      Length   : U8 := 0;
      Extended : Boolean := False;
      Data     : Frame_Data := (others => 0);
   end record;

   procedure Init (Bitrate_Kbps : U32 := 500);

   procedure Poll;

   --  True if a frame is available.  Out-param F holds it.
   function Receive (F : out Frame) return Boolean;

   --  Send a frame (e.g. OBD-II PID request).
   procedure Send (F : Frame);

end Hal.CANBus;
