    .global _start

	.section .vectors,"a"
stack:		.4byte 0x2000
reset:		.4byte _start

	.text

.equ		GPIO_IN,  0x100000
.equ		GPIO_OUT, 0x100004
.equ		GPIO_OE,  0x100008

.equ		UART_RXBUF,		0x100100
.equ		UART_TXBUF,		0x100100
.equ		UART_INTEN,		0x100101
.equ		UART_INTID,		0x100102
.equ		UART_FIFOCTRL,	0x100102
.equ		UART_LINECTRL,	0x100103
.equ		UART_MODEMCTRL,	0x100104
.equ		UART_LINESTAT,	0x100105
.equ		UART_MODEMSTAT, 0x100106
.equ		UART_DIVLAT1,	0x100100 /*clk div lsb, muss zuletzt geschrieben werden! */
.equ		UART_DIVLAT2,	0x100101 /* clk div msb */

.equ		UART_DIVVAL1,   27 /* 50 MHz / (16*115200) = 27,13 */
.equ		UART_DIVVAL2,	0

_start:
			movel %a7, %fp
			moveal #0, %a5
			moveal #0, %a4
			moveal #0, %a3
			moveal #0, %a2
			moveal #0, %a1
			moveal #0, %a0

			movel #0, %d7
			movel #0, %d6
			movel #0, %d5
			movel #0, %d4
			movel #0, %d3
			movel #0, %d2
			movel #0, %d1
			movel #0, %d0
			ORI.W  #0xF000, %SR
			ANDI.W #0xF000, %SR

			move.l #0x000000FF, GPIO_OE
			move.l #0x000000FF, GPIO_OUT

uart_init:	
			/* enable access to divisor registers */
			move.b #0x80, UART_LINECTRL 
			/* setup 115200 baud (for 50mhz uart clk) */
			move.b #UART_DIVVAL2, UART_DIVLAT2
			move.b #UART_DIVVAL1, UART_DIVLAT1
			/* enable access to rx/tx buffers */
			move.b #0x07, UART_LINECTRL /*8bit chars and 2 stop bits*/

			movea.l	#msg, %a0
hello:		move.b (%a0)+, %d0
			tst.b %d0
			beq.s loop
			move.b %d0, UART_TXBUF
			bra.s hello
			

loop:
			jmp loop
.data
msg:		.asciz "Hallo Welt!\n"
