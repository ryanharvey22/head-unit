# head-unit — Bare-Metal Ada on Raspberry Pi 4

Firmware scaffold in Ada on BCM2711 (Cortex-A72, AArch64): no OS, no Ada
standard library — boot to your own code.

Vehicle hardware intent is documented in [HARDWARE.md](HARDWARE.md). Product
mockups live under `design_concepts/`.

## Repo layout

```
src/           Ada sources; `screen_background.ads` = v1 on-screen palette
common/        boot.S, linker.ld, config.txt, runtime.c (memset/memcpy/…)
tools/         flash_sd.sh — build + copy to SD card
design_concepts/  UI mockups (reference only)
```

## Build and flash

```bash
sudo apt install gcc-12-aarch64-linux-gnu gnat-12-aarch64-linux-gnu

make                    # → build/kernel8.img
make flash              # build then copy kernel + config.txt to mounted BOOT
```

First-time SD setup: put Pi 4 firmware files on the FAT partition (`bootcode.bin`,
`start4.elf`, `fixup4.dat`, `bcm2711-rpi-4-b.dtb`). If they are missing,
`FETCH_FIRMWARE=1 ./tools/flash_sd.sh` downloads them.

Default firmware behavior: [`Head_Unit_Main.Run`](src/head_unit_main.adb) idle
loops using [`Hal.Clock.Wait_Ms`](src/hal-clock.adb). Add UART, mailbox
framebuffer, and drivers in `src/` as you implement them.

## References for UART and HDMI bring-up

- [BCM2711 peripherals PDF](https://datasheets.raspberrypi.com/bcm2711/bcm2711-peripherals.pdf)
- [Pi boot firmware files](https://github.com/raspberrypi/firmware/tree/master/boot)
- [Mailbox property interface](https://github.com/raspberrypi/firmware/wiki/Mailbox-property-interface) — framebuffer tags use **channel 8** (not the deprecated framebuffer-only mailbox API).
- [rockytriton LLD — `rpi_bm/part13`](https://github.com/rockytriton/LLD/tree/main/rpi_bm/part13) — timers, mailbox tutorials (Pi 4 needs dual mailbox status registers MBOX0/MBOX1).
- [rockytriton LLD — `rpi_bm/part14`](https://github.com/rockytriton/LLD/tree/main/rpi_bm/part14) — property-tag framebuffer sequence (physical/virtual size, depth, allocate, pitch).
- Linux **legacy framebuffer** driver (tag ordering and quirks): search the kernel tree for `bcm2708_fb` / VideoCore mailbox framebuffer handling as a cross-check.

[`common/boot.S`](common/boot.S) enters AArch64 from firmware with EL-aware setup;
[`common/linker.ld`](common/linker.ld) places the stack at `__stack_top`.
