# Bare Metal Hello World – Raspberry Pi 4

Minimal “Hello World” that runs without an OS. Output is over **UART0** (serial), so you need a serial connection to see it.

## Requirements

- **Toolchain:** ARM AArch64 bare-metal GCC  
  Download: [ARM GNU Toolchain](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads)  
  Use the “AArch64 bare-metal target (aarch64-none-elf)” build.

- **SD card** with official Raspberry Pi 4 boot files (from [raspberrypi/firmware](https://github.com/raspberrypi/firmware/tree/master/boot)).

## Build

```bash
cd bare-metal
make
```

This produces `kernel8.img`.

## Run on the Pi 4

1. **Prepare the SD card**
   - Use a FAT32 **boot** partition that already boots the Pi 4 (so it has the right `start4.elf`, `fixup4.dat`, etc.).
   - Copy `kernel8.img` to the root of that partition.
   - Copy `config.txt` to the same place (or merge its contents into the existing `config.txt` so that `arm_64bit=1`, `kernel=kernel8.img`, and optionally `enable_uart=1` are set).

2. **Serial connection**
   - Connect a USB–UART adapter to **GPIO 14 (TX)** and **GPIO 15 (RX)** (and GND). Pi 4 UART0 is 3.3 V; use 115200 8N1.
   - Or use the Pi’s USB-C for power only and rely on the GPIO UART for output.

3. **Boot**
   - Power the Pi. You should see:
     ```
     Hello World from bare metal Raspberry Pi 4!
     ```

If you don’t see anything, check wiring, baud rate (115200), and that the boot partition has the correct Pi 4 firmware files.

## Files

| File         | Purpose                          |
|-------------|-----------------------------------|
| `boot.S`    | Entry, stack setup, BSS zero, call `main` |
| `main.c`    | UART init, print string           |
| `linker.ld` | Link script (load at `0x80000`)   |
| `config.txt`| Boot options for the SD card      |

## Toolchain on Linux (optional)

```bash
# Example: extract and use
wget https://developer.arm.com/.../arm-gnu-toolchain-...-x86_64-aarch64-none-elf.tar.xz
tar xf arm-gnu-toolchain-*.tar.xz
export PATH="$PWD/arm-gnu-toolchain-.../bin:$PATH"
make
```
