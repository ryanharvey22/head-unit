/*
 * mailbox.h — VideoCore mailbox interface for Raspberry Pi 4
 *
 * The mailbox is how the ARM asks the GPU to do things:
 * set up a framebuffer, query hardware info, adjust clocks, etc.
 *
 * You fill a 16-byte-aligned buffer with "property tags",
 * send the buffer address to MBOX_WRITE, then read MBOX_READ
 * to get the GPU's response.
 */

#ifndef MAILBOX_H
#define MAILBOX_H

#include <stdint.h>

/*
 * Max words in a mailbox message buffer.
 * 256 bytes is plenty for framebuffer setup.
 */
#define MBOX_BUF_SIZE 64

/*
 * Shared message buffer — must be 16-byte aligned.
 * Declared in mailbox.c.
 */
extern volatile uint32_t mbox_buf[MBOX_BUF_SIZE]
    __attribute__((aligned(16)));

/*
 * Send the contents of mbox_buf to the GPU on the given channel
 * and wait for a response.  Returns 1 on success, 0 on failure.
 *
 * Channel 8 = property tags (the one you almost always want).
 */
int mbox_call(uint8_t channel);

/* Property tag channel */
#define MBOX_CH_PROP 8

/* Common property tags for framebuffer setup */
#define TAG_SET_PHYS_WH     0x00048003
#define TAG_SET_VIRT_WH     0x00048004
#define TAG_SET_VIRT_OFFSET 0x00048009
#define TAG_SET_DEPTH       0x00048005
#define TAG_SET_PIXEL_ORDER 0x00048006
#define TAG_ALLOC_FB        0x00040001
#define TAG_GET_PITCH       0x00040008
#define TAG_END             0x00000000

#endif
