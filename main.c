/*
 * main.c — Boot diagnostic for Raspberry Pi bare-metal
 *
 * Auto-detects Pi 3 vs Pi 4 by reading the ARM CPU ID register.
 * Tests HDMI output (cyan screen) and LED blink simultaneously.
 */

#include <stdint.h>
#include "mailbox.h"

/* ---- CPU detection ---- */

static uint32_t gpio_base;
static volatile uint32_t *gpset;
static volatile uint32_t *gpclr;
static uint32_t act_bit;

static inline uint32_t read_midr(void)
{
    uint64_t val;
    asm volatile ("mrs %0, midr_el1" : "=r"(val));
    return (uint32_t)((val >> 4) & 0xFFF);
}

static void led_init(void)
{
    uint32_t part = read_midr();

    if (part == 0xD08) {
        /* Pi 4 — Cortex-A72, peripherals at 0xFE000000 */
        gpio_base = 0xFE200000;
        volatile uint32_t *gpfsel4 = (volatile uint32_t *)(unsigned long)(gpio_base + 0x10);
        uint32_t sel = *gpfsel4;
        sel &= ~(7u << 6);
        sel |=  (1u << 6);
        *gpfsel4 = sel;
        gpset = (volatile uint32_t *)(unsigned long)(gpio_base + 0x20);  /* GPSET1 */
        gpclr = (volatile uint32_t *)(unsigned long)(gpio_base + 0x2C);  /* GPCLR1 */
        act_bit = (1u << 10);  /* GPIO 42 */
    } else {
        /* Pi 3 — Cortex-A53, peripherals at 0x3F000000 */
        gpio_base = 0x3F200000;
        volatile uint32_t *gpfsel2 = (volatile uint32_t *)(unsigned long)(gpio_base + 0x08);
        uint32_t sel = *gpfsel2;
        sel &= ~(7u << 27);
        sel |=  (1u << 27);
        *gpfsel2 = sel;
        gpset = (volatile uint32_t *)(unsigned long)(gpio_base + 0x1C);  /* GPSET0 */
        gpclr = (volatile uint32_t *)(unsigned long)(gpio_base + 0x28);  /* GPCLR0 */
        act_bit = (1u << 29);  /* GPIO 29 */
    }
}

/* ---- Delay ---- */

static void delay(uint32_t count)
{
    while (count--)
        asm volatile ("nop");
}

/* ---- Framebuffer ---- */

static uint32_t *framebuffer;
static uint32_t  fb_pitch;

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
    /* Set up LED for correct Pi model */
    led_init();

    /* Turn LED on immediately as proof we got this far */
    *gpclr = act_bit;    /* try active-low */
    *gpset = act_bit;    /* try active-high */

    /* Try HDMI — if this works, you'll see cyan */
    int have_fb = fb_init(1280, 720);
    if (have_fb) {
        uint32_t stride = fb_pitch / 4;
        for (uint32_t y = 0; y < 720; y++)
            for (uint32_t x = 0; x < 1280; x++)
                framebuffer[y * stride + x] = 0xFF00D2FF;
    }

    /* Blink LED forever */
    for (;;) {
        *gpset = act_bit;
        delay(200000000);
        *gpclr = act_bit;
        delay(200000000);
    }
}
