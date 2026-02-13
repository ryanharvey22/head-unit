/* Raspberry Pi 4 loads kernel at 0x80000; BCM2711 */
ENTRY(_start)

SECTIONS
{
    . = 0x80000;

    .text : {
        *(.text.boot)
        *(.text .text.*)
    }

    .rodata : {
        *(.rodata .rodata.*)
    }

    .data : {
        *(.data .data.*)
    }

    .bss : {
        __bss_start = .;
        *(.bss .bss.*)
        *(COMMON)
        __bss_end = .;
        __stack_bottom = .;
        . = . + 0x10000;   /* 64 KiB stack */
        __stack_top = .;
    }

    . = ALIGN(4096);
    __end = .;
}
