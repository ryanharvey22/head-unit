/*
 * boot.S — ARM64 entry point, sets up stack and calls main()
 *
 * Shared between C and Ada — the only difference is what
 * language main() is written in.
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
