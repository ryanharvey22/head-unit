/*
 * boot.S — Minimal LED blink, pure assembly, no C runtime
 *
 * If this doesn't blink, the kernel isn't loading.
 */

.section .text.boot
.global _start

_start:
    /* Only run on core 0 */
    mrs     x0, mpidr_el1
    and     x0, x0, #3
    cbnz    x0, park

    /* Load GPIO base address: 0xFE200000 */
    movz    x0, #0xFE20, lsl #16

    /* Read GPFSEL4 (offset 0x10) */
    ldr     w1, [x0, #0x10]

    /* Clear bits [8:6] for GPIO 42 */
    movz    w2, #0x1C0
    bic     w1, w1, w2

    /* Set bits [8:6] = 001 (output) */
    orr     w1, w1, #0x40
    str     w1, [x0, #0x10]

    /* w3 = ACT_BIT = 1 << 10 */
    movz    w3, #0x400

blink:
    /* GPSET1 (offset 0x20) — drive high */
    str     w3, [x0, #0x20]

    /* Delay */
    movz    x4, #0x200, lsl #16
1:  subs    x4, x4, #1
    bne     1b

    /* GPCLR1 (offset 0x2C) — drive low */
    str     w3, [x0, #0x2C]

    /* Delay */
    movz    x4, #0x200, lsl #16
1:  subs    x4, x4, #1
    bne     1b

    b       blink

park:
    wfe
    b       park
