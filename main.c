/*
 * main.c — Blink the onboard ACT LED on Raspberry Pi 4
 *
 * The ACT LED is wired to GPIO 42 on the BCM2711.
 * On the Pi 4B it is active-low (pull low = LED on).
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
    uint32_t sel = GPFSEL4;
    sel &= ~(7u << 6);
    sel |=  (1u << 6);
    GPFSEL4 = sel;

    for (;;) {
        GPCLR1 = ACT_BIT;      /* LED on  (active-low) */
        delay(150000000);
        GPSET1 = ACT_BIT;      /* LED off */
        delay(150000000);
    }
}
