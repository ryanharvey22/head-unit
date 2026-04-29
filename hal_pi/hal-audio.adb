--  hal-audio.adb (Pi) — STUB
--
--  TODO: PWM driver on GPIO 18/19, eventually I2S DAC.

package body Hal.Audio is

   procedure Init (Sample_Rate_Hz : U32 := 44_100) is
      pragma Unreferenced (Sample_Rate_Hz);
   begin
      null;
   end Init;

   procedure Write (Samples : PCM_Buffer) is
      pragma Unreferenced (Samples);
   begin
      null;
   end Write;

   procedure Set_Volume (Vol : U8) is
      pragma Unreferenced (Vol);
   begin
      null;
   end Set_Volume;

end Hal.Audio;
