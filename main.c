/*
 * main.c — Blink the onboard ACT LED on Raspberry Pi 4
 *
 * The ACT LED is wired to GPIO 42 on the BCM2711.
 *
 * GPIO register map (from the BCM2711 datasheet):
 *   GPFSEL4  — function select for GPIOs 40-49 (3 bits per pin)
 *   GPSET1   — set-high for GPIOs 32-57
 *   GPCLR1   — set-low  for GPIOs 32-57
 *
 * GPIO 42 sits in GPFSEL4 at bits [8:6].
 * In SET1/CLR1 it is bit 10  (42 - 32 = 10).
 */

#include <stdint.h>

/* ---- BCM2711 GPIO registers ---- */

#define MMIO_BASE   0xFE000000
#define GPIO_BASE   (MMIO_BASE + 0x200000)

#define GPFSEL4     (*(volatile uint32_t *)(GPIO_BASE + 0x10))
#define GPSET1      (*(volatile uint32_t *)(GPIO_BASE + 0x20))
#define GPCLR1      (*(volatile uint32_t *)(GPIO_BASE + 0x2C))

#define ACT_BIT     (1u << 10)      /* GPIO 42 in the SET1/CLR1 bank */

/* ---- Busy-wait delay ---- */

static void delay(uint32_t count)
{
    while (count--)
        asm volatile ("nop");
}

/* ---- Entry point (called from boot.S) ---- */

void main(void)
{
    /*
     * Configure GPIO 42 as output.
     *
     * GPFSEL4 assigns a 3-bit function code to each of GPIOs 40-49.
     * GPIO 42 is bits [8:6].  The code 001 = output.
     *
     * We read-modify-write so we only touch GPIO 42's bits and
     * leave every other pin's configuration alone.
     */
    uint32_t sel = GPFSEL4;        /* read current register             */
    sel &= ~(7u << 6);             /* clear bits [8:6] → 000            */
    sel |=  (1u << 6);             /* set   bits [8:6] → 001 = output   */
    GPFSEL4 = sel;                  /* write back to hardware            */

    for (;;) {
        GPCLR1 = ACT_BIT;      /* LED on  (active-low on Pi 4B) */
        delay(150000000);
        GPSET1 = ACT_BIT;      /* LED off */
        delay(150000000);
    }
}
