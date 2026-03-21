/*
 * main.c — Framebuffer test for Raspberry Pi 4 bare-metal
 *
 * Fills the screen with a solid color over HDMI to confirm
 * the boot chain is working.  If you see color, your code is running.
 */

#include <stdint.h>
#include "mailbox.h"

/* ---- Framebuffer state ---- */

static uint32_t *framebuffer;
static uint32_t  fb_width;
static uint32_t  fb_height;
static uint32_t  fb_pitch;

static int fb_init(uint32_t width, uint32_t height)
{
    int i = 0;

    mbox_buf[i++] = 0;                 /* total size — filled below       */
    mbox_buf[i++] = 0;                 /* request code                    */

    mbox_buf[i++] = TAG_SET_PHYS_WH;
    mbox_buf[i++] = 8;
    mbox_buf[i++] = 0;
    mbox_buf[i++] = width;
    mbox_buf[i++] = height;

    mbox_buf[i++] = TAG_SET_VIRT_WH;
    mbox_buf[i++] = 8;
    mbox_buf[i++] = 0;
    mbox_buf[i++] = width;
    mbox_buf[i++] = height;

    mbox_buf[i++] = TAG_SET_VIRT_OFFSET;
    mbox_buf[i++] = 8;
    mbox_buf[i++] = 0;
    mbox_buf[i++] = 0;
    mbox_buf[i++] = 0;

    mbox_buf[i++] = TAG_SET_DEPTH;
    mbox_buf[i++] = 4;
    mbox_buf[i++] = 0;
    mbox_buf[i++] = 32;

    mbox_buf[i++] = TAG_SET_PIXEL_ORDER;
    mbox_buf[i++] = 4;
    mbox_buf[i++] = 0;
    mbox_buf[i++] = 1;                 /* RGB */

    mbox_buf[i++] = TAG_ALLOC_FB;
    mbox_buf[i++] = 8;
    mbox_buf[i++] = 0;
    mbox_buf[i++] = 4096;              /* alignment */
    mbox_buf[i++] = 0;

    mbox_buf[i++] = TAG_GET_PITCH;
    mbox_buf[i++] = 4;
    mbox_buf[i++] = 0;
    mbox_buf[i++] = 0;

    mbox_buf[i++] = TAG_END;

    mbox_buf[0] = (uint32_t)(i * sizeof(uint32_t));

    if (!mbox_call(MBOX_CH_PROP))
        return 0;

    uint32_t fb_addr = mbox_buf[28];
    fb_pitch         = mbox_buf[33];

    if (fb_addr == 0)
        return 0;

    /* Convert GPU bus address to ARM physical address */
    fb_addr &= 0x3FFFFFFF;

    framebuffer = (uint32_t *)(unsigned long)fb_addr;
    fb_width    = width;
    fb_height   = height;

    return 1;
}

/* ---- Entry point (called from boot.S) ---- */

void main(void)
{
    if (!fb_init(1280, 720))
        for (;;) {}     /* halt if framebuffer setup fails */

    /*
     * Fill entire screen with bright cyan.
     * If you see this color, your code is running.
     */
    uint32_t stride = fb_pitch / 4;
    for (uint32_t y = 0; y < fb_height; y++)
        for (uint32_t x = 0; x < fb_width; x++)
            framebuffer[y * stride + x] = 0xFF00D2FF;

    for (;;) {}
}
