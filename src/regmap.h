#ifndef __REGMAP_H__
#define __REGMAP_H__

#ifndef uint8_t
typedef unsigned char uint8_t;
#endif

#ifndef uint16_t
typedef unsigned short uint16_t;
#endif

#ifndef uint32_t
typedef unsigned long uint32_t;
#endif


// Boot control
#define BOOTCTRL            (*(volatile uint8_t*)0x80000000)
#define BOOTCTRL_RESET      (1<<0)
#define BOOTCTRL_RAMEN      (1<<1)
#define BOOTCTRL_BOOTSEL    (1<<2)

// GPIO
#define GPIO_IN             (*(volatile uint32_t*)0x80000100)
#define GPIO_OUT            (*(volatile uint32_t*)0x80000104)
#define GPIO_OE             (*(volatile uint32_t*)0x80000108)

// UART
#define UART_RXBUF          (*(volatile uint8_t*)0x80000200)
#define UART_TXBUF          (*(volatile uint8_t*)0x80000200)

#define UART_INTEN          (*(volatile uint8_t*)0x80000201)
#define UART_INTID          (*(volatile uint8_t*)0x80000202)
#define UART_FIFOCTRL       (*(volatile uint8_t*)0x80000202)
#define UART_LINECTRL       (*(volatile uint8_t*)0x80000203)
#define UART_MODEMCTRL      (*(volatile uint8_t*)0x80000204)

#define UART_LINESTAT       (*(volatile uint8_t*)0x80000205)
#define UART_LINESTAT_DR    (1<<0) // Data ready
#define UART_LINESTAT_FE    (1<<5) // Transmit fifo empty

#define UART_MODEMSTAT      (*(volatile uint8_t*)0x80000206)
#define UART_DIVLAT1        (*(volatile uint8_t*)0x80000200)
#define UART_DIVLAT2        (*(volatile uint8_t*)0x80000201)

#define TIMER1_CTL          (*(volatile uint16_t*)0x80000300)
#define TIMER1_MOD          (*(volatile uint16_t*)0x80000302)
#define TIMER1_CNT          (*(volatile uint16_t*)0x80000304)
#define TIMER2_CTL          (*(volatile uint16_t*)0x80000310)
#define TIMER2_MOD          (*(volatile uint16_t*)0x80000312)
#define TIMER2_CNT          (*(volatile uint16_t*)0x80000314)

#define SDSPI_CMD           (*(volatile uint32_t*)0x80000400)
#define SDSPI_DAT           (*(volatile uint32_t*)0x80000404)
#define SDSPI_FIFOA         (*(volatile uint32_t*)0x80000408)
#define SDSPI_FIFOB         (*(volatile uint32_t*)0x8000040C)

#endif
