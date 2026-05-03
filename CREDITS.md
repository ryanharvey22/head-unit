# Credits and attribution

This file records documentation, design, and third-party influences used by the **head-unit** firmware. If you redistribute or publish derivatives, keep these notices with the project where reasonable.

---

## Raspberry Pi / BCM2711 bring-up

- **BCM2711 ARM Peripherals** — Raspberry Pi Ltd datasheet used for MMIO layout and GPIO/UART/timer context.  
  https://datasheets.raspberrypi.com/bcm2711/bcm2711-peripherals.pdf  

- **Mailbox property interface (channel 8)** — tag list format and framebuffer-related tags.  
  https://github.com/raspberrypi/firmware/wiki/Mailbox-property-interface  

- **Boot firmware blobs** (`start4.elf`, `fixup4.dat`, DTB, etc.) — Raspberry Pi Ltd / Raspberry Pi firmware distribution.  
  https://github.com/raspberrypi/firmware  

- **Educational bare-metal sequences** — mailbox property-tag ordering and framebuffer setup were cross-checked against community tutorials, notably **rockytriton**’s low-level driver examples (timers / mailbox / framebuffer sequence):  
  https://github.com/rockytriton/LLD/tree/main/rpi_bm/part13  
  https://github.com/rockytriton/LLD/tree/main/rpi_bm/part14  

- **Linux kernel** — useful for verifying mailbox / firmware behaviour (e.g. `drivers/firmware/raspberrypi.c`, mailbox drivers); used as a reference only, not copied code.

---

## Bitmap font (`src/gfx_font.adb`)

The on-screen font is a **5×7** fixed-width bitmap: each glyph is seven rows of five columns (plus spacing), rasterised with `Hal.Display.Fill_Rect`.

- **Glyph data**: The hex tables in `gfx_font.adb` were **produced for this repository** (assembled into Ada constants here). They follow the same **visual conventions** as countless **dot-matrix / “hitachi HD44780 style”** 5×7 diagrams and open-source glyph tables used in embedded graphics.

- **Stylistic reference (not a byte-for-byte copy)**: Similar glyph aesthetics appear in widely reused open fonts, e.g. the bitmap font in the **Adafruit GFX Library** (`glcdfont.c`, **BSD**). That upstream file is typically **5×8** and differs in packing and exact bitmaps; we cite it as a **cultural / licensing reference** for “small embedded bitmap fonts,” not as the literal source of our tables.  
  https://github.com/adafruit/Adafruit-GFX-Library  

If you replace `Glyph_Table` with glyphs imported from a specific font file, **retain that font’s license file** next to this project and update this section.

---

## UI palette and layout

- **Colour palette and composition** are defined in-repo under `design_concepts/README.md`, aligned with the PNG mockups there.

- **Typography direction** in the design doc (“JetBrains Mono Bold feel”) refers to **JetBrains Mono** as a **visual reference only**; this firmware does not bundle JetBrains fonts or trademarks—only a small bitmap font above.

---

## Trademarks

**Raspberry Pi** is a trademark of Raspberry Pi Ltd. This project is not endorsed by or affiliated with Raspberry Pi Ltd, Adafruit Industries, or JetBrains.
