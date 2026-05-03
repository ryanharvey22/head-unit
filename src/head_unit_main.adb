--  head_unit_main.adb — Display init before UART (TX can spin); magenta smoke test
--
--  Debug LED: BCM 17 / header pin 11 → resistor → LED → pin 9 (GND).
--  Boot: two long flashes (NOP spin). Then Init entry (one flash); buffer cleared (one blip);
--  two quick blips = about to Mailbox.Call; three flashes = inside Call.
--  Slow blink during mailbox spin-waits = waiting on VideoCore.
--  After Call: display OK → ~1 Hz heartbeat (timer); FAILED → fast blink.

with Hal.Clock;
with Hal.Display;
with Hal.GPIO;
with Hal.UART;
with Mailbox;

package body Head_Unit_Main is

   LED : constant Hal.U32 := Hal.GPIO.Debug_LED_BCM;

   Boot_On  : constant Natural := 22_000_000;
   Boot_Off : constant Natural := 22_000_000;

   procedure Spin_Boot_Pulse is
   begin
      Hal.GPIO.Write (LED, True);
      Hal.Clock.Busy_Wait_Loops (Boot_On);
      Hal.GPIO.Write (LED, False);
      Hal.Clock.Busy_Wait_Loops (Boot_Off);
   end Spin_Boot_Pulse;

   procedure Pulse (Ms_On, Ms_Off : Hal.U32) is
   begin
      Hal.GPIO.Write (LED, True);
      Hal.Clock.Wait_Ms (Ms_On);
      Hal.GPIO.Write (LED, False);
      Hal.Clock.Wait_Ms (Ms_Off);
   end Pulse;

   procedure Run is
      Ok : Boolean;
   begin
      Hal.GPIO.Init_Output (LED);
      Hal.GPIO.Write (LED, False);
      Spin_Boot_Pulse;
      Spin_Boot_Pulse;

      Ok := Hal.Display.Init;
      if Ok then
         --  Obvious solid (XRGB magenta); Screen_Background is nearly black on HDMI.
         Hal.Display.Fill (Hal.Display.Magenta);
         Hal.Display.Flush;
      end if;

      Hal.UART.Init;
      if Ok then
         Hal.UART.Put_Line ("display: init OK");
         Hal.UART.Put_String ("  fb=");
         Hal.UART.Put_Hex (Hal.Display.Last_FB_Address);
         Hal.UART.Put_String (" pitch=");
         Hal.UART.Put_Hex (Hal.Display.Last_Scanline_Pitch);
         Hal.UART.New_Line;
      else
         Hal.UART.Put_Line ("display: init FAILED");
         Hal.UART.Put_String ("  mbox buf[1]=");
         Hal.UART.Put_Hex (Mailbox.Buffer (1));
         Hal.UART.New_Line;
      end if;

      loop
         if Ok then
            Pulse (50, 950);
         else
            Pulse (150, 150);
         end if;
      end loop;
   end Run;

end Head_Unit_Main;
