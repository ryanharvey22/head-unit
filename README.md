# head-unit — Bare-Metal Raspberry Pi 4

A from-scratch bare-metal project targeting the Raspberry Pi 4 (BCM2711, ARM Cortex-A72, AArch64). No operating system, no standard library — just your code talking directly to hardware.

## What "bare-metal" means

When the Pi powers on, the VideoCore GPU runs its own bootloader from ROM, reads `config.txt` from the SD card's FAT32 partition, then loads `kernel8.img` into RAM at address `0x80000` and releases the ARM cores. There is no Linux, no scheduler, no libc. Your code owns the machine.

```
Power on
  └─ GPU bootloader (ROM)
       └─ reads config.txt from SD card
            └─ loads kernel8.img to 0x80000
                 └─ releases ARM cores
                      └─ _start (boot.S) runs on core 0
                           └─ main() in C
```

## Project structure

```
boot.S       ARM64 entry point — parks cores 1-3, sets up stack, zeroes BSS, calls main()
linker.ld    Memory layout — places .text.boot at 0x80000
main.c       PL011 UART driver — inits GPIO 14/15, prints hello, echoes serial input
config.txt   Tells the GPU to load kernel8.img in 64-bit mode
Makefile     Cross-compiles to kernel8.img
```

## Building

You need an AArch64 bare-metal cross-compiler. The toolchain prefix defaults to `aarch64-none-elf-` but can be overridden.

### Install the toolchain

**Arm GNU Toolchain (recommended):**

Download from https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads — pick the `aarch64-none-elf` hosted on your OS (Linux x86_64, macOS, etc).

Extract it and add the `bin/` directory to your PATH.

**Or on Ubuntu/Debian:**

```bash
sudo apt install gcc-aarch64-linux-gnu
make CROSS=aarch64-linux-gnu-
```

### Build

```bash
make
```

This produces `kernel8.img` (~a few hundred bytes).

## Flashing to SD card

1. Format a microSD card as FAT32
2. Copy these files to the root of the card:
   - `kernel8.img` (your binary)
   - `config.txt`
   - The Pi's firmware files: `bootcode.bin`, `start4.elf`, `fixup4.dat` — download from https://github.com/raspberrypi/firmware/tree/master/boot
3. Insert SD card into the Pi and power on

## Connecting serial

The UART is on GPIO 14 (TX) and GPIO 15 (RX) at 115200 baud, 8-N-1. Connect a USB-to-TTL serial adapter:

```
Pi GPIO 14 (TX)  →  Adapter RX
Pi GPIO 15 (RX)  →  Adapter TX
Pi GND           →  Adapter GND
```

Open a terminal on your computer:

```bash
# Linux
screen /dev/ttyUSB0 115200

# macOS
screen /dev/tty.usbserial-* 115200
```

You should see:

```
head-unit: bare-metal boot ok
UART echo ready — type something
```

## What to try next

Each step introduces a new hardware concept:

1. **GPIO / LED blink** — write to GPSET/GPCLR registers, add a delay loop
2. **System timer** — read the BCM2711 free-running counter for accurate timing
3. **Interrupts** — configure the GIC-400, handle UART RX interrupts instead of polling
4. **Framebuffer** — use the VideoCore mailbox interface to set up a display
5. **I2C driver** — talk to sensors (GPS module, distance sensor) over the BSC peripheral
6. **OBD-II** — wire an L9637D K-line transceiver and speak ISO 9141 to the car

## Key references

- [BCM2711 ARM Peripherals](https://datasheets.raspberrypi.com/bcm2711/bcm2711-peripherals.pdf) — the datasheet for all MMIO registers
- [Raspberry Pi Firmware](https://github.com/raspberrypi/firmware/tree/master/boot) — GPU bootloader files needed on the SD card
- [ARM Architecture Reference Manual (ARMv8-A)](https://developer.arm.com/documentation/ddi0487/latest) — the instruction set bible
