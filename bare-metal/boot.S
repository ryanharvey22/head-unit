.section ".text.boot"
.global _start

_start:
    /* Only run on core 0; other cores park */
    mrs     x0, mpidr_el1
    and     x0, x0, #0xFF
    cbz     x0, 1f
    /* Cores 1–3: wait in a loop */
    wfe
    b       _start
1:
    /* Set stack pointer (grows down) */
    ldr     x0, =__stack_top
    mov     sp, x0

    /* Zero BSS */
    ldr     x0, =__bss_start
    ldr     x1, =__bss_end
2:  cmp     x0, x1
    b.hs    3f
    str     xzr, [x0], #8
    b       2b
3:
    /* Jump to C */
    bl      main
    /* If main returns, hang */
    b       .
