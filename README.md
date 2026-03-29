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

## Key references

- [BCM2711 ARM Peripherals](https://datasheets.raspberrypi.com/bcm2711/bcm2711-peripherals.pdf)
- [Raspberry Pi Firmware](https://github.com/raspberrypi/firmware/tree/master/boot)
- [ARM Architecture Reference Manual (ARMv8-A)](https://developer.arm.com/documentation/ddi0487/latest)
- [Ada on Bare Metal](https://learn.adacore.com)
