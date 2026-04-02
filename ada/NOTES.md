# Ada Bare-Metal Notes

## Boot Chain — How the Pi 4 Actually Starts

When you plug in power, here's what happens step by step:

### 1. SoC ROM (hardwired in silicon)
The BCM2711 chip has a tiny bootloader burned into its ROM at the factory. This is not software you can change. It runs on the **VideoCore GPU**, not the ARM cores. The ARM cores are held in reset at this point — they're doing nothing.

The ROM looks at the SPI EEPROM on the board for the second-stage bootloader.

### 2. EEPROM Bootloader (on-board flash)
The Pi 4 has a small SPI flash chip on the PCB that holds the second-stage bootloader. This was programmed at the factory and gets updated when you run `rpi-eeprom-update` under Raspberry Pi OS.

This bootloader initializes SDRAM (the 1/2/4 GB of RAM on your board) and then loads `start4.elf` from the SD card's FAT32 partition.

Note: `bootcode.bin` on the SD card is **ignored on Pi 4**. It's only used on Pi 1/2/3 where there's no EEPROM. We include it for compatibility but the Pi 4 doesn't read it.

### 3. start4.elf (GPU firmware, runs on VideoCore)
This is the main GPU firmware. It's a proprietary Broadcom/Raspberry Pi binary that runs on the VideoCore IV GPU — not on the ARM cores. It does a LOT:

- Reads `config.txt` and applies settings
- Sets up clock trees (CPU clock, GPU clock, UART clock, etc.)
- Configures SDRAM timings
- Initializes HDMI, USB, PCIe, and other peripherals
- **Reads the Device Tree Blob (DTB) and uses it to configure hardware**
- Loads `kernel8.img` into RAM at address `0x80000`
- Sets up the ARM stub (a tiny piece of code at address `0x0`)
- Releases the ARM cores from reset

After this, `start4.elf` keeps running on the GPU in the background. It handles power management, thermal throttling, and the mailbox interface (how ARM talks to the GPU).

### 4. ARM Stub (address 0x0)
A small piece of ARM code placed at address `0x0` by the firmware. It runs on the ARM Cortex-A72 cores for the first time. It:

- Initializes the GIC-400 interrupt controller
- Drops from EL3 to EL2 (exception levels — like privilege rings in x86)
- Parks cores 1-3 in a wait loop
- Jumps core 0 to `0x80000` (where your kernel is loaded)

### 5. Your Kernel (address 0x80000)
This is `kernel8.img` — your code. `boot.S` runs first (it's placed at `.text.boot` which the linker script puts at the start). Then it calls `_ada_main` which is your Ada procedure.

## The Device Tree Blob (DTB) — What It Is and Why We Need It

### What is it?
A Device Tree Blob (`.dtb` file) is a binary data structure that describes the hardware on the board. It's compiled from a human-readable Device Tree Source (`.dts`) file using the `dtc` compiler.

The format is an **open standard** — not Raspberry Pi proprietary. It was invented by Open Firmware (Sun/IBM) and adopted by the Linux kernel community in ~2012 for ARM platforms. The spec is maintained at [devicetree.org](https://devicetree.org/).

### What's in it?
The DTB for our board (`bcm2711-rpi-4-b.dtb`) describes:

- Memory layout (where RAM starts and ends)
- CPU cores (4x Cortex-A72, their addresses)
- Interrupt controller (GIC-400) configuration
- Clock tree definitions (which clocks feed which peripherals)
- GPIO pin assignments and alternate functions
- UART, SPI, I2C controller addresses and configurations
- USB, PCIe, Ethernet controller details
- HDMI, audio, camera/display interfaces

### What's proprietary vs open?
- **DTB format**: Open standard, not proprietary
- **The specific .dtb file contents**: Written by Raspberry Pi engineers, open-source, hosted on GitHub
- **start4.elf**: **Proprietary** Broadcom binary. This is the only closed-source piece in the boot chain. Its source code has never been released.
- **fixup4.dat**: Proprietary, works with start4.elf to configure memory split between ARM and GPU

### Why did we need it?
Without the DTB, `start4.elf` didn't know how to properly initialize the hardware for the ARM cores. Our old `device_tree=` config was telling the firmware "don't load any device tree," which apparently caused it to skip critical ARM initialization on Pi 4.

On older Pi models (1/2/3), the firmware could boot without a DTB because the hardware was simpler. The Pi 4's BCM2711 has more complex hardware (GIC-400 interrupt controller, PCIe, etc.) that requires proper initialization via the device tree.

## System Timer

The BCM2711 has a free-running hardware timer at `0xFE003000`. The lower 32 bits of the counter are at offset `0x04` (so `0xFE003004`). It ticks at **1 MHz** (1 tick = 1 microsecond) regardless of the CPU clock speed.

We use this instead of nop-counting because:
- Nop loops depend on CPU clock speed, which the firmware configures via the DTB
- The system timer always runs at 1 MHz, giving reliable wall-clock timing
- It's the same timer Linux uses for its clocksource on Pi

In our code: `Wait_Microseconds(500_000)` = wait 500,000 microseconds = 0.5 seconds.

## Files on the SD Card

| File | Source | Purpose |
|------|--------|---------|
| `bootcode.bin` | Raspberry Pi firmware repo | First-stage bootloader (Pi 1/2/3 only, ignored on Pi 4) |
| `start4.elf` | Raspberry Pi firmware repo | GPU firmware, initializes all hardware |
| `fixup4.dat` | Raspberry Pi firmware repo | Memory split configuration for start4.elf |
| `bcm2711-rpi-4-b.dtb` | Raspberry Pi firmware repo | Hardware description for the Pi 4 Model B |
| `config.txt` | We wrote this | Boot configuration (64-bit mode, kernel name, UART) |
| `kernel8.img` | We compiled this | Our bare-metal Ada program |

## config.txt Settings

```
arm_64bit=1         — Boot ARM cores in AArch64 (64-bit) mode
kernel=kernel8.img  — Explicitly name the kernel file to load
enable_uart=1       — Initialize the mini-UART at boot (useful for serial debug)
```

## Memory Map

```
0x00000000  ARM stub (placed by firmware, initializes cores)
0x00080000  kernel8.img loaded here (our code)
   ...
0xFE000000  Peripheral MMIO base (GPIO, UART, timers, etc.)
0xFE003004  System Timer counter (1 MHz, 32-bit)
0xFE200000  GPIO registers base
0xFE200004  GPFSEL1 (function select for GPIO 10-19)
0xFE20001C  GPSET0  (set output high for GPIO 0-31)
0xFE200028  GPCLR0  (set output low for GPIO 0-31)
```
