/*
 * linker.ld — Memory layout for bare-metal RPi 4
 *
 * GPU loads kernel8.img at 0x80000.  .text.boot must come first
 * so _start is the entry point at that address.
 *
 * Stack must NOT live at 0x80000 — AArch64 stacks grow downward into
 * addresses below SP.  Everything below the kernel load address is often
 * firmware/GPU-reserved on Pi 4; starting SP there faults instantly.
 */

PROVIDE(__stack_top = 0x800000);   /* 8 MiB — safe high RAM for SP */

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
