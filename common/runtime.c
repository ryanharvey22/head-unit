/*
 * runtime.c — Minimal freestanding runtime for bare-metal Ada.
 *
 * The Ada compiler emits calls to memset/memcpy for array aggregate
 * assignments and slice copies.  We're linking with -nostdlib, so
 * libc isn't available — provide our own.
 */

#include <stddef.h>
#include <stdint.h>

void *memset(void *dst, int c, size_t n)
{
    uint8_t *d = (uint8_t *)dst;
    while (n--) {
        *d++ = (uint8_t)c;
    }
    return dst;
}

void *memcpy(void *dst, const void *src, size_t n)
{
    uint8_t *d = (uint8_t *)dst;
    const uint8_t *s = (const uint8_t *)src;
    while (n--) {
        *d++ = *s++;
    }
    return dst;
}

void *memmove(void *dst, const void *src, size_t n)
{
    uint8_t *d = (uint8_t *)dst;
    const uint8_t *s = (const uint8_t *)src;
    if (d < s || d >= s + n) {
        while (n--) *d++ = *s++;
    } else {
        d += n;
        s += n;
        while (n--) *--d = *--s;
    }
    return dst;
}

int memcmp(const void *a, const void *b, size_t n)
{
    const uint8_t *p = a, *q = b;
    while (n--) {
        if (*p != *q) return *p - *q;
        p++; q++;
    }
    return 0;
}
