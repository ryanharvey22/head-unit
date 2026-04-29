--  head_unit_main.adb — Application loop

with Hal; use Hal;
with Hal.Display;
with Hal.UART;
with Hal.Input; use type Hal.Input.Event_Kind;
with Hal.GPS;
with Hal.CANBus;
with Hal.Audio;
with Hal.Clock;
with UI.Screen;

package body Head_Unit_Main is

   procedure Run is
      Display_Ok : Boolean;
      E          : Hal.Input.Event;
   begin
      Hal.UART.Init;
      Hal.UART.Put_Line ("");
      Hal.UART.Put_Line ("===============================");
      Hal.UART.Put_Line ("  HEAD UNIT  bare metal Ada");
      Hal.UART.Put_Line ("===============================");

      Display_Ok := Hal.Display.Init;
      if not Display_Ok then
         Hal.UART.Put_Line ("Display init failed");
      end if;

      Hal.Input.Init;
      Hal.GPS.Init;
      Hal.CANBus.Init;
      Hal.Audio.Init;
      UI.Screen.Init;

      Hal.UART.Put_Line ("Entering main loop");

      loop
         exit when UI.Screen.Should_Quit;

         Hal.Input.Poll;
         Hal.GPS.Poll;
         Hal.CANBus.Poll;

         loop
            E := Hal.Input.Get_Next_Event;
            exit when E.Kind = Hal.Input.None;
            UI.Screen.Handle_Event (E);
         end loop;

         UI.Screen.Update;
         UI.Screen.Draw;

         --  Cap framerate at ~60 fps (16.6 ms/frame)
         Hal.Clock.Wait_Ms (16);
      end loop;

      Hal.UART.Put_Line ("Quit requested, exiting");
   end Run;

end Head_Unit_Main;
