/*
 * main.c — Boot diagnostic: fill HDMI screen bright green + try ACT LED
 *
 * If you see a green screen, the kernel is running.
 * If you still see rainbow, the kernel never loaded.
 */

#include <stdint.h>

#define MMIO_BASE    0xFE000000
#define GPIO_BASE    (MMIO_BASE + 0x200000)
#define MBOX_BASE    (MMIO_BASE + 0xB880)

#define MBOX_READ    (*(volatile uint32_t *)(MBOX_BASE + 0x00))
#define MBOX_STATUS  (*(volatile uint32_t *)(MBOX_BASE + 0x18))
#define MBOX_WRITE   (*(volatile uint32_t *)(MBOX_BASE + 0x20))

#define MBOX_FULL    0x80000000u
#define MBOX_EMPTY   0x40000000u

#define GPFSEL4      (*(volatile uint32_t *)(GPIO_BASE + 0x10))
#define GPSET1       (*(volatile uint32_t *)(GPIO_BASE + 0x20))
#define GPCLR1       (*(volatile uint32_t *)(GPIO_BASE + 0x2C))

static volatile uint32_t __attribute__((aligned(16))) mbox[36];

static int mbox_call(void)
{
    uint32_t r = (uint32_t)((uint64_t)&mbox & ~0xF) | 8;

    while (MBOX_STATUS & MBOX_FULL)
        asm volatile ("nop");

    MBOX_WRITE = r;

    for (;;) {
        while (MBOX_STATUS & MBOX_EMPTY)
            asm volatile ("nop");
        if (MBOX_READ == r)
            return mbox[1] == 0x80000000;
    }
}

static void delay(uint32_t count)
{
    while (count--)
        asm volatile ("nop");
}

void main(void)
{
    mbox[0]  = 35 * 4;
    mbox[1]  = 0;

    mbox[2]  = 0x48003;     /* set physical display size */
    mbox[3]  = 8;
    mbox[4]  = 0;
    mbox[5]  = 640;
    mbox[6]  = 480;

    mbox[7]  = 0x48004;     /* set virtual display size */
    mbox[8]  = 8;
    mbox[9]  = 0;
    mbox[10] = 640;
    mbox[11] = 480;

    mbox[12] = 0x48009;     /* set virtual offset */
    mbox[13] = 8;
    mbox[14] = 0;
    mbox[15] = 0;
    mbox[16] = 0;

    mbox[17] = 0x48005;     /* set depth */
    mbox[18] = 4;
    mbox[19] = 0;
    mbox[20] = 32;

    mbox[21] = 0x48006;     /* set pixel order */
    mbox[22] = 4;
    mbox[23] = 0;
    mbox[24] = 1;

    mbox[25] = 0x40001;     /* allocate buffer */
    mbox[26] = 8;
    mbox[27] = 0;
    mbox[28] = 4096;
    mbox[29] = 0;

    mbox[30] = 0x40008;     /* get pitch */
    mbox[31] = 4;
    mbox[32] = 0;
    mbox[33] = 0;

    mbox[34] = 0;           /* end tag */

    if (mbox_call()) {
        uint32_t *fb = (uint32_t *)((uint64_t)(mbox[28] & 0x3FFFFFFF));
        uint32_t pitch = mbox[33] / 4;

        for (uint32_t y = 0; y < 480; y++)
            for (uint32_t x = 0; x < 640; x++)
                fb[y * pitch + x] = 0xFF00FF00;
    }

    /* Also try ACT LED blink */
    uint32_t sel = GPFSEL4;
    sel &= ~(7u << 6);
    sel |= (1u << 6);
    GPFSEL4 = sel;

    for (;;) {
        GPSET1 = (1u << 10);
        delay(500000000);
        GPCLR1 = (1u << 10);
        delay(500000000);
    }
}
