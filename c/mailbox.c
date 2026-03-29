/*
 * mailbox.c — VideoCore mailbox driver
 *
 * The mailbox sits at MMIO_BASE + 0xB880.  To talk to the GPU:
 *
 *   1. Wait until STATUS says the mailbox isn't full
 *   2. Write (buffer_address | channel) to MBOX_WRITE
 *   3. Wait until STATUS says there's a response
 *   4. Read from MBOX_READ, check the channel matches
 *   5. Check the response code in the buffer
 */

#include "mailbox.h"

#define MMIO_BASE   0xFE000000
#define MBOX_BASE   (MMIO_BASE + 0xB880)

#define MBOX_READ   (*(volatile uint32_t *)(MBOX_BASE + 0x00))
#define MBOX_STATUS (*(volatile uint32_t *)(MBOX_BASE + 0x18))
#define MBOX_WRITE  (*(volatile uint32_t *)(MBOX_BASE + 0x20))

#define MBOX_FULL   (1u << 31)   /* status bit: can't write yet */
#define MBOX_EMPTY  (1u << 30)   /* status bit: nothing to read */

/* 16-byte-aligned buffer shared between ARM and GPU */
volatile uint32_t mbox_buf[MBOX_BUF_SIZE]
    __attribute__((aligned(16)));

int mbox_call(uint8_t channel)
{
    /*
     * The GPU reads a 32-bit value from MBOX_WRITE:
     *   bits [31:4] = buffer address (must be 16-byte aligned)
     *   bits  [3:0] = channel number
     */
    uint32_t addr = (uint32_t)(unsigned long)&mbox_buf[0];
    uint32_t msg  = (addr & ~0xFu) | (channel & 0xF);

    /* Wait until the mailbox has room */
    while (MBOX_STATUS & MBOX_FULL) {}

    /* Send our request */
    MBOX_WRITE = msg;

    /* Wait for the GPU's response */
    for (;;) {
        while (MBOX_STATUS & MBOX_EMPTY) {}

        uint32_t resp = MBOX_READ;

        /* Check that this response is for our channel */
        if ((resp & 0xF) == channel) {
            /* Response code is in mbox_buf[1]: 0x80000000 = success */
            return (mbox_buf[1] == 0x80000000);
        }
    }
}
