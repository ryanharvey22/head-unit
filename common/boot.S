/*
 * boot.S — ARM64 entry point for bare-metal Ada on Raspberry Pi 4
 *
 * Parks cores 1-3, sets up stack, zeroes BSS, calls _ada_main.
 * Shared across all projects via symlink or copy.
 */

.section .text.boot
.global _start

_start:
    mrs     x0, mpidr_el1
    and     x0, x0, #3
    cbnz    x0, park

    ldr     x0, =_start
    mov     sp, x0

    ldr     x0, =__bss_start
    ldr     x1, =__bss_end
.Lbss:
    cmp     x0, x1
    b.ge    .Lmain
    str     xzr, [x0], #8
    b       .Lbss

.Lmain:
    bl      _ada_main
    b       park

park:
    wfe
    b       park
