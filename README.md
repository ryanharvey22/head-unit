# head-unit — Bare-Metal Ada on Raspberry Pi 4

Radar signal processing from scratch on bare metal. No OS, no standard library — just Ada talking directly to hardware on a Raspberry Pi 4 (BCM2711, Cortex-A72, AArch64).

## Project Structure

```
common/          Shared boot code, linker script, config
  boot.S         ARM64 entry point (parks cores, sets stack, calls Ada)
  linker.ld      Memory layout (kernel loads at 0x80000)
  config.txt     Pi boot config (64-bit, UART enabled)
  Makefile.inc   Shared build rules

blink_light/     LED blink on GPIO 17 — the "hello world" (DONE)
  main.adb       Toggles GPIO 17 using hardware timer

uart/            Serial output over mini-UART at 115200 baud (DONE)
  uart.ads       UART driver spec (Init, Put_Char, Put_String, Put_Hex, etc.)
  uart.adb       UART driver body (mini-UART on GPIO 14/15)
  main.adb       Demo: prints messages + timer values over serial

fft/             FFT and DSP library (IN PROGRESS)
  fixed_point.ads/adb   Q15 fixed-point arithmetic (multiply, saturating add/sub)
  sin_table.ads         Precomputed sine lookup table (TODO: generate values)
  fft.ads/adb           Radix-2 Cooley-Tukey FFT (TODO: implement)
  main.adb              Test harness: generate signal, run FFT, print over UART
```

## Building

Requires `aarch64-linux-gnu-gcc-12` with GNAT (Ada) support.

```bash
# Ubuntu
sudo apt install gcc-12-aarch64-linux-gnu gnat-12-aarch64-linux-gnu

# Build any project
cd blink_light && make    # or cd uart && make, etc.
```

## Flashing to SD Card

Format a microSD as FAT32 (MBR). Copy these files to the root:

| File | Source |
|------|--------|
| `start4.elf` | [Pi firmware repo](https://github.com/raspberrypi/firmware/tree/master/boot) |
| `fixup4.dat` | Pi firmware repo |
| `bcm2711-rpi-4-b.dtb` | Pi firmware repo **(required on Pi 4!)** |
| `config.txt` | `common/config.txt` |
| `kernel8.img` | Built from whichever project you want to run |

```bash
sudo cp common/config.txt /media/you/BOOT/
sudo cp uart/kernel8.img /media/you/BOOT/
sudo sync && sudo umount /media/you/BOOT
```

## Wiring

**LED blink (blink_light/):**
```
Pin 11 (GPIO 17) → LED long leg (+)
                    LED short leg (-) → Pin 9 (GND)
```

**UART serial (uart/, fft/):**
```
Pin 8  (GPIO 14, TX) → USB-serial adapter RX
Pin 6  (GND)         → USB-serial adapter GND
```
On your laptop: `screen /dev/ttyUSB0 115200`

## Roadmap — DSP / Radar Signal Processing

### Phase 1 — DSP Library (bare-metal Pi, no extra hardware)

- [x] **LED blink** — Verified bare-metal code execution
- [x] **UART driver** — Serial output for testing and debugging
- [ ] **Fixed-point math** — Q15 saturating arithmetic
- [ ] **Sine table** — Precomputed Q15 sin/cos lookup
- [ ] **FFT** — Radix-2 Cooley-Tukey, in-place, fixed-point
- [ ] **Chirp generation** — Linear FM waveform synthesis
- [ ] **Matched filter** — Cross-correlation against known waveform
- [ ] **CFAR detection** — Adaptive threshold target detector
- [ ] **HDMI spectrum display** — Draw FFT output to framebuffer

### Phase 2 — RF Integration

- [ ] RTL-SDR receiver (IQ sample capture over USB)
- [ ] Flipper Zero CC1101 as 433 MHz transmitter (SPI from Pi)
- [ ] Bistatic radar: transmit with Flipper, receive with SDR
- [ ] Passive radar using FM broadcast illuminators

### Phase 3 — Full Radar Processor

- [ ] Range-Doppler map (2D FFT)
- [ ] Pulse compression
- [ ] Kalman filter target tracking
- [ ] Real-time HDMI display with range/velocity readout

## Key References

- [BCM2711 ARM Peripherals](https://datasheets.raspberrypi.com/bcm2711/bcm2711-peripherals.pdf)
- [Raspberry Pi Firmware](https://github.com/raspberrypi/firmware/tree/master/boot)
- [ARM Architecture Reference Manual (ARMv8-A)](https://developer.arm.com/documentation/ddi0487/latest)
- [Ada on Bare Metal](https://learn.adacore.com)
- [devicetree.org](https://devicetree.org/) — DTB specification
