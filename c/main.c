/*
 * main.c — Blink the green ACT LED on Raspberry Pi 4
 *
 * ACT LED = GPIO 42
 * GPFSEL4 controls GPIOs 40-49, GPIO 42 is at bits [8:6]
 * GPSET1/GPCLR1 control GPIOs 32-63, GPIO 42 is bit 10
 */

#include <stdint.h>

#define MMIO_BASE   0xFE000000
#define GPIO_BASE   (MMIO_BASE + 0x200000)

#define GPFSEL4     (*(volatile uint32_t *)(GPIO_BASE + 0x10))
#define GPSET1      (*(volatile uint32_t *)(GPIO_BASE + 0x20))
#define GPCLR1      (*(volatile uint32_t *)(GPIO_BASE + 0x2C))

#define LED_BIT     (1u << 10)

static void delay(uint32_t count)
{
    while (count--)
        asm volatile ("nop");
}

void main(void)
{
    uint32_t sel = GPFSEL4;
    sel &= ~(7u << 6);         /* clear bits [8:6] for GPIO 42 */
    sel |=  (1u << 6);         /* set to 001 = output */
    GPFSEL4 = sel;

    for (;;) {
        GPSET1 = LED_BIT;      /* pin high — LED on */
        delay(200000000);
        GPCLR1 = LED_BIT;      /* pin low — LED off */
        delay(200000000);
    }
}
