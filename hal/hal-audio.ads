--  hal-audio.ads — PCM audio output abstraction
--
--  Pi:   PWM stereo on GPIO 18/19 (start), I2S DAC later
--  Sim:  SDL2 audio device, callback-driven

with Hal; use Hal;

package Hal.Audio is

   --  Sample format: 16-bit signed stereo, interleaved L/R
   type PCM_Sample is new I16;
   type PCM_Buffer is array (Natural range <>) of PCM_Sample;

   procedure Init (Sample_Rate_Hz : U32 := 44_100);

   --  Push a buffer of samples to the audio device.  Blocks if the
   --  hardware queue is full.
   procedure Write (Samples : PCM_Buffer);

   --  Set master volume (0..255).
   procedure Set_Volume (Vol : U8);

end Hal.Audio;
