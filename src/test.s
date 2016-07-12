    .global _start

	.section .vectors,"a"
stack:		.4byte 0x2000
reset:		.4byte _start

	.text

.equ		UART_RXBUF,		0x100100
.equ		UART_TXBUF,		0x100100
.equ		UART_INTEN,		0x100101
.equ		UART_INTID,		0x100102
.equ		UART_FIFOCTRL,	0x100102
.equ		UART_LINECTRL,	0x100103
.equ		UART_MODEMCTRL,	0x100104
.equ		UART_LINESTAT,	0x100105
.equ		UART_MODEMSTAT, 0x100106
.equ		UART_DIVLAT1,	0x100100 /*clk div LSB */
.equ		UART_DIVLAT2,	0x100101 /* clk div msb */

.equ		UART_DIVVAL1,   27 /* 50 MHz / (16*115200) = 27,13 */
.equ		UART_DIVVAL2,	0

_start:
uart_init:	
			move.b #0, 0x100100
			move.b #1, 0x100101
			move.b #2, 0x100102
			move.b #3, 0x100103
			move.b #4, 0x100104

loop:
			jmp loop
    
