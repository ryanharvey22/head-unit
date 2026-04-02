# head-unit — Bare-Metal Raspberry Pi 4

A from-scratch bare-metal project targeting the Raspberry Pi 4 (BCM2711, ARM Cortex-A72, AArch64). No operating system, no standard library — just your code talking directly to hardware.

Two implementations of the same LED blink program:

```
c/       C implementation
ada/     Ada implementation
```

Both produce the same `kernel8.img` that blinks an LED on GPIO 17 (header pin 11).

## Building

Each directory has its own Makefile. You need an AArch64 bare-metal cross-compiler.

```bash
# C version
cd c && make CROSS=aarch64-none-elf-

# Ada version (requires GNAT for AArch64)
cd ada && make CROSS=aarch64-none-elf-
```

## Flashing to SD card

1. Format a microSD card as FAT32 (MBR)
2. Copy to the root of the card:
   - `kernel8.img` and `config.txt` from whichever version you built
   - Pi firmware files: `bootcode.bin`, `start4.elf`, `fixup4.dat` from https://github.com/raspberrypi/firmware/tree/master/boot
3. Insert SD card into Pi, connect LED to GPIO 17 + GND, power on

## Wiring

```
Pin 11 (GPIO 17) → resistor (220-1kΩ) → LED (+)
                                          LED (-) → Pin 9 (GND)
```

## Roadmap — DSP / Radar Signal Processing

The long-term goal is to build a radar signal processing pipeline in Ada on bare metal. This targets skills used in real radar systems (AESA, FMCW, pulse-Doppler) built with Ada in the defense industry.

### Phase 1 — DSP Library (bare-metal Pi, no extra hardware)

- [ ] **FFT** — Fast Fourier Transform in fixed-point Ada. The core algorithm for all frequency-domain analysis. Used in every radar, sonar, and communications system.
- [ ] **Chirp generation** — Synthesize linear frequency-modulated (LFM) waveforms. This is the transmit waveform used in FMCW and pulse-compression radar.
- [ ] **Matched filtering** — Correlate received signal against the known transmit waveform to pull weak target returns out of noise. Maximizes SNR.
- [ ] **CFAR detection** — Constant False Alarm Rate detector. Adaptive threshold that decides "that's a target" vs background clutter, independent of noise level.
- [ ] **HDMI spectrum display** — Output FFT results to the framebuffer as a real-time spectrum analyzer / range profile display.

### Phase 2 — RF Integration (requires hardware)

- [ ] RTL-SDR receiver on the Pi (IQ sample capture)
- [ ] Flipper Zero CC1101 as 433 MHz transmitter (SPI control from Pi)
- [ ] Bistatic radar: transmit with Flipper, receive with SDR, process in Ada
- [ ] Passive radar using FM broadcast towers as illuminators

### Phase 3 — Full Radar Processor

- [ ] Range-Doppler map (2D FFT)
- [ ] Pulse compression
- [ ] Target tracking (Kalman filter)
- [ ] Real-time HDMI display with range/velocity readout

### Hardware

| Item | Purpose | ~Cost |
|------|---------|-------|
| Raspberry Pi 4B | Bare-metal processing platform | (have) |
| Flipper Zero | Sub-GHz RF transmitter (CC1101) | (have) |
| RTL-SDR USB dongle | Wideband RF receiver (24-1766 MHz) | $25 |
| USB-to-serial UART cable | Pi serial debug output | $5 |

## Key references

- [BCM2711 ARM Peripherals](https://datasheets.raspberrypi.com/bcm2711/bcm2711-peripherals.pdf)
- [Raspberry Pi Firmware](https://github.com/raspberrypi/firmware/tree/master/boot)
- [ARM Architecture Reference Manual (ARMv8-A)](https://developer.arm.com/documentation/ddi0487/latest)
- [Ada on Bare Metal](https://learn.adacore.com)
