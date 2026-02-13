/*
 * Bare metal Hello World for Raspberry Pi 4 (BCM2711).
 * Outputs via UART0 – connect serial (e.g. USB‑UART) to see it.
 */

#define UART0_BASE  0xFE201000

#define UART0_DR    (*(volatile unsigned int *)(UART0_BASE + 0x00))
#define UART0_FR    (*(volatile unsigned int *)(UART0_BASE + 0x18))
#define UART0_IBRD  (*(volatile unsigned int *)(UART0_BASE + 0x24))
#define UART0_FBRD  (*(volatile unsigned int *)(UART0_BASE + 0x28))
#define UART0_LCRH  (*(volatile unsigned int *)(UART0_BASE + 0x2C))
#define UART0_CR    (*(volatile unsigned int *)(UART0_BASE + 0x30))

#define UART_FR_TXFF  (1 << 5)
#define UART_CR_UARTEN (1 << 0)
#define UART_CR_TXE   (1 << 8)
#define UART_LCRH_FEN (1 << 4)
#define UART_LCRH_WLEN_8 (3 << 5)

static void uart_putc(char c)
{
    while (UART0_FR & UART_FR_TXFF)
        ;
    UART0_DR = (unsigned int)c;
}

static void uart_puts(const char *s)
{
    while (*s)
        uart_putc(*s++);
}

static void uart_init(void)
{
    /* 48 MHz UART clock, 115200 baud: 48000000 / (16 * 115200) = 26.04 → 26 */
    UART0_IBRD = 26;
    UART0_FBRD = 3;   /* 0.04 * 64 ≈ 3 */
    UART0_LCRH = UART_LCRH_FEN | UART_LCRH_WLEN_8;
    UART0_CR   = UART_CR_UARTEN | UART_CR_TXE;
}

void main(void)
{
    uart_init();
    uart_puts("\r\nHello World from bare metal Raspberry Pi 4!\r\n");
    for (;;)
        ;
}
