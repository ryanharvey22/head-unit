/*
 * boot.S — ARM64 entry point for Raspberry Pi 4
 *
 * Parks cores 1-3, sets up stack, disables D-cache for GPU mailbox coherency,
 * zeroes BSS, calls _ada_main.
 */

.section .text.boot
.global _start

_start:
    mrs     x0, mpidr_el1
    and     x0, x0, #3
    cbnz    x0, park

    ldr     x0, =__stack_top
    mov     sp, x0

    mrs     x3, CurrentEL
    ubfx    x3, x3, #2, #2
    cmp     x3, #2
    b.ne    .Ldc_try_el1
    mrs     x0, sctlr_el2
    bic     x0, x0, #4
    msr     sctlr_el2, x0
    isb
    b       .Ldc_done
.Ldc_try_el1:
    cmp     x3, #1
    b.ne    .Ldc_done
    mrs     x0, sctlr_el1
    bic     x0, x0, #4
    msr     sctlr_el1, x0
    isb
.Ldc_done:

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
