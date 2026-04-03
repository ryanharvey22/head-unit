/*
 * linker.ld — Memory layout for bare-metal RPi 4
 *
 * GPU loads kernel8.img at 0x80000.  .text.boot must come first
 * so _start is the entry point at that address.
 */

SECTIONS
{
    . = 0x80000;

    .text : {
        *(.text.boot)
        *(.text .text.*)
    }

    .rodata : { *(.rodata .rodata.*) }

    .data : { *(.data .data.*) }

    .bss ALIGN(8) : {
        __bss_start = .;
        *(.bss .bss.*)
        *(COMMON)
        __bss_end = .;
    }
}
