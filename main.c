/*
 * main.c — Boot test for Raspberry Pi 4 bare-metal
 *
 * Two tests in one:
 *   1. Fills the HDMI screen with cyan (proves code is running)
 *   2. Toggles GPIO 42 both ways (covers active-high and active-low)
 */

#include <stdint.h>
#include "mailbox.h"

/* ---- BCM2711 GPIO registers ---- */

#define MMIO_BASE   0xFE000000
#define GPIO_BASE   (MMIO_BASE + 0x200000)

#define GPFSEL4     (*(volatile uint32_t *)(GPIO_BASE + 0x10))
#define GPSET1      (*(volatile uint32_t *)(GPIO_BASE + 0x20))
#define GPCLR1      (*(volatile uint32_t *)(GPIO_BASE + 0x2C))

#define ACT_BIT     (1u << 10)

/* ---- Framebuffer state ---- */

static uint32_t *framebuffer;
static uint32_t  fb_pitch;

static void delay(uint32_t count)
{
    while (count--)
        asm volatile ("nop");
}

static int fb_init(uint32_t width, uint32_t height)
{
    int i = 0;
    mbox_buf[i++] = 0;
    mbox_buf[i++] = 0;

    mbox_buf[i++] = TAG_SET_PHYS_WH;
    mbox_buf[i++] = 8;  mbox_buf[i++] = 0;
    mbox_buf[i++] = width;  mbox_buf[i++] = height;

    mbox_buf[i++] = TAG_SET_VIRT_WH;
    mbox_buf[i++] = 8;  mbox_buf[i++] = 0;
    mbox_buf[i++] = width;  mbox_buf[i++] = height;

    mbox_buf[i++] = TAG_SET_VIRT_OFFSET;
    mbox_buf[i++] = 8;  mbox_buf[i++] = 0;
    mbox_buf[i++] = 0;  mbox_buf[i++] = 0;

    mbox_buf[i++] = TAG_SET_DEPTH;
    mbox_buf[i++] = 4;  mbox_buf[i++] = 0;
    mbox_buf[i++] = 32;

    mbox_buf[i++] = TAG_SET_PIXEL_ORDER;
    mbox_buf[i++] = 4;  mbox_buf[i++] = 0;
    mbox_buf[i++] = 1;

    mbox_buf[i++] = TAG_ALLOC_FB;
    mbox_buf[i++] = 8;  mbox_buf[i++] = 0;
    mbox_buf[i++] = 4096;  mbox_buf[i++] = 0;

    mbox_buf[i++] = TAG_GET_PITCH;
    mbox_buf[i++] = 4;  mbox_buf[i++] = 0;
    mbox_buf[i++] = 0;

    mbox_buf[i++] = TAG_END;
    mbox_buf[0] = (uint32_t)(i * sizeof(uint32_t));

    if (!mbox_call(MBOX_CH_PROP)) return 0;

    uint32_t fb_addr = mbox_buf[28];
    fb_pitch         = mbox_buf[33];
    if (fb_addr == 0) return 0;

    fb_addr &= 0x3FFFFFFF;
    framebuffer = (uint32_t *)(unsigned long)fb_addr;
    return 1;
}

/* ---- Entry point ---- */

void main(void)
{
    /* Set up GPIO 42 as output */
    uint32_t sel = GPFSEL4;
    sel &= ~(7u << 6);
    sel |=  (1u << 6);
    GPFSEL4 = sel;

    /* Try framebuffer — fill screen cyan if it works */
    if (fb_init(1280, 720)) {
        uint32_t stride = fb_pitch / 4;
        for (uint32_t y = 0; y < 720; y++)
            for (uint32_t x = 0; x < 1280; x++)
                framebuffer[y * stride + x] = 0xFF00D2FF;
    }

    /* Blink LED regardless — try both polarities */
    for (;;) {
        GPSET1 = ACT_BIT;
        delay(150000000);
        GPCLR1 = ACT_BIT;
        delay(150000000);
    }
}
