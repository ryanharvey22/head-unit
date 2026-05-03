--  hal-gpio.ads — Minimal BCM2711 GPIO output for bring-up (Pi 4 MMIO @ 0xFE000000).
--
--  Default debug LED wiring (active high: GPIO → resistor ~330Ω → LED → GND):
--    BCM GPIO 17 → physical pin 11; LED return → physical pin 9 (GND).
--  Avoid BCM 2, 4, 6 (LCD), 14 and 15 (mini-UART), and other buses you use.

with Hal;

package Hal.GPIO is

   Debug_LED_BCM : constant Hal.U32 := 17;

   procedure Init_Output (BCM_Pin : Hal.U32);

   procedure Write (BCM_Pin : Hal.U32; High : Boolean);

end Hal.GPIO;
