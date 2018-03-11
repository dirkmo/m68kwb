.equ        BOOTCTRL_CTRL, 0x80000000

.equ		GPIO_IN,  0x80000100
.equ		GPIO_OUT, 0x80000104
.equ		GPIO_OE,  0x80000108

.equ        UART_RXBUF,     0x80000200
.equ        UART_TXBUF,     0x80000200
.equ        UART_INTEN,     0x80000201
.equ        UART_INTID,     0x80000202
.equ        UART_FIFOCTRL,  0x80000202
.equ        UART_LINECTRL,  0x80000203
.equ        UART_MODEMCTRL, 0x80000204
.equ        UART_LINESTAT,  0x80000205
.equ        UART_MODEMSTAT, 0x80000206
.equ        UART_DIVLAT1,   0x80000200 /*clk div lsb, muss zuletzt geschrieben werden! */
.equ        UART_DIVLAT2,   0x80000201 /* clk div msb */

.equ		TIMER1_CTL, 0x80000300
.equ		TIMER1_MOD, 0x80000302
.equ		TIMER1_CNT, 0x80000304

.equ		TIMER2_CTL, 0x80000310
.equ		TIMER2_MOD, 0x80000312
.equ		TIMER2_CNT, 0x80000314

.equ        SDSPI_CTRL,    0x80000400
.equ        SDSPI_DAT,    0x80000404
.equ        SDSPI_FIFO0,  0x80000408
.equ        SDSPI_FIFO1,  0x8000040C
