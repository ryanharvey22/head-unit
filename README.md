# head-unit — Bare-Metal Ada Head Unit for Raspberry Pi 4

A car head unit written in Ada, running bare-metal on a Raspberry Pi 4
(BCM2711, Cortex-A72, AArch64). No operating system, no standard library —
just Ada talking to hardware directly.

Target vehicle: **1996-97 Lexus LX 450** (K-line OBD-II). Future-proofed
for any 2008+ CAN-equipped car. See [HARDWARE.md](HARDWARE.md) for the
full bill of materials.

## Repo layout

```
app/         Application loop and main entry
ui/          Widgets and pages (target-agnostic)
hal/         Abstract HAL specs — what the firmware needs from the world
hal_pi/      Real BCM2711 drivers (MMIO, mailbox)
hal_qemu/    QEMU implementations (UART + clock work; rest are stubs)
nmea/        Pure NMEA 0183 parser (no HAL dep, native-testable)
obd2/        Pure SAE J1979 OBD-II PID decoder (no HAL dep, native-testable)
tests/       Native Ada unit tests for protocol packages + fixtures
common/      boot.S, linker.ld, config.txt, runtime.c
tools/qemu/  QEMU launch script
```

## Three things you can build

| Command | What it builds | What it's for |
|---|---|---|
| `make` (or `make TARGET=qemu`) | `build/qemu/kernel8.img` | Boot in QEMU; UART logs to terminal. Fast smoke test. |
| `make TARGET=pi` | `build/pi/kernel8.img` | Flash to SD card. Real hardware. |
| `make test` | Host-native unit test binaries | Unit-test pure-logic packages (nmea, obd2). Milliseconds. |

## Testing strategy

Embedded firmware testing is split along the line between **driver** code
(touches MMIO, only meaningful on real hardware) and **logic** code
(parsers, decoders, state machines — totally portable Ada).

Drivers stay tiny (~30 lines each in `hal_pi/`).  Logic lives in standalone
packages (`nmea/`, `obd2/`) that have no HAL dependency and can be exercised
by native unit tests in milliseconds:

```
$ make test
test_nmea: starts in clean state
  PASS
test_nmea: valid GGA sentence is accepted
  PASS
...
test_obd2: Engine RPM at 1000 rpm
  PASS
...
All host unit tests PASSED.
```

The drivers verify on real hardware via UART debug logging. QEMU is only
useful for boot/CPU/UART/timer smoke tests — it does not emulate GPIO, I2C,
SPI, USB, or HDMI, so most peripheral driver work has to happen on the Pi
itself.

A handy QEMU trick for end-to-end testing: pipe a real serial device into
QEMU's virtual UART so the firmware reads bytes from a real GPS module on
your laptop:

```bash
qemu-system-aarch64 -machine raspi4b -kernel build/qemu/kernel8.img \
    -serial /dev/ttyUSB0
```

## Prerequisites

```bash
sudo apt install \
    gcc-12-aarch64-linux-gnu \
    gnat-12-aarch64-linux-gnu \
    gnat-12 \
    qemu-system-arm
```

## Implementation roadmap

Each peripheral has the same pattern: a tiny driver in `hal_pi/`, plus
optional pure-logic packages and tests for any non-trivial parsing.

### Phase 1 — Scaffold (done)
- [x] HAL architecture (pi + qemu targets)
- [x] HDMI framebuffer + UART working on Pi
- [x] QEMU dev loop with UART logging
- [x] Pure-logic packages (`nmea/`, `obd2/`) with native unit tests
- [x] Driver shims wired to logic packages

### Phase 2 — Peripherals (in order of "biggest unlock per dollar")

1. **GPS** — order u-blox NEO-M8N + USB-UART adapter
   - [ ] Implement `Parse_GGA` in `nmea/nmea-parser.adb`
   - [ ] Uncomment the lat/lon assertions in `tests/test_nmea.adb`
   - [ ] Implement `hal_pi/hal-gps.adb`: open PL011 UART0, drain bytes
         into `Nmea.Parser.Feed`
2. **K-line OBD-II** — order L9637D + OBD-II pigtail + breadboard
   - [ ] Implement `hal_pi/hal-canbus.adb`: ISO 9141-2 slow init,
         10.4 kbaud, request/response framing
   - [ ] Add fixture-based test in `tests/test_obd2.adb` for the K-line
         frame layout (separate from PID decode, which is already done)
3. **Display + touch** — order 10.1" HDMI capacitive screen
   - [ ] Choose I2C (FT5316) vs USB HID for touch — see HARDWARE.md
   - [ ] Implement `hal_pi/hal-input.adb`
4. **Audio** — order HiFiBerry DAC+ + TPA3116 amp + harness
   - [ ] Implement `hal_pi/hal-audio.adb`: I2S transmit
   - [ ] Add a simple PCM sample-mixer logic package + tests
5. **Power + cabling + dash kit** — install in the LX 450

## Flashing to SD Card

Format SD card as FAT32 (single partition). Copy these to the root:

| File | Source |
|---|---|
| `bootcode.bin` | [Pi firmware repo](https://github.com/raspberrypi/firmware/tree/master/boot) |
| `start4.elf` | Pi firmware repo |
| `fixup4.dat` | Pi firmware repo |
| `bcm2711-rpi-4-b.dtb` | Pi firmware repo (REQUIRED on Pi 4) |
| `config.txt` | `common/config.txt` |
| `kernel8.img` | `build/pi/kernel8.img` |

## Key references

- [HARDWARE.md](HARDWARE.md) — full BOM and wiring
- [BCM2711 ARM Peripherals](https://datasheets.raspberrypi.com/bcm2711/bcm2711-peripherals.pdf)
- [Raspberry Pi Firmware](https://github.com/raspberrypi/firmware/tree/master/boot)
- [SAE J1979 OBD-II PIDs](https://en.wikipedia.org/wiki/OBD-II_PIDs)
- [NMEA 0183 sentence reference](http://aprs.gids.nl/nmea/)
- [Ada on Bare Metal (AdaCore)](https://learn.adacore.com)
