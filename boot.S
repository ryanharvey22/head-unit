/*
 * boot.S — ARM64 bare-metal entry point for Raspberry Pi 4
 *
 * The GPU loads kernel8.img to 0x80000 and begins execution here.
 * We park cores 1-3, set up a stack for core 0, zero BSS, then
 * branch to main().
 */

.section .text.boot
.global _start

_start:
    /* ---- Park non-primary cores ---- */
    mrs     x0, mpidr_el1
    and     x0, x0, #3
    cbz     x0, .Lcore0

.Lpark:
    wfe
    b       .Lpark

.Lcore0:
    /* ---- Stack grows downward from _start (0x80000) ---- */
    ldr     x0, =_start
    mov     sp, x0

    /* ---- Zero .bss ---- */
    ldr     x0, =__bss_start
    ldr     x1, =__bss_end

.Lbss:
    cmp     x0, x1
    b.ge    .Lmain
    str     xzr, [x0], #8
    b       .Lbss

.Lmain:
    bl      main
    b       .Lpark
