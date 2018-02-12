    .global _start
    .global __ram_end
    .global _int1vec
    .global _int2vec
    .global _int3vec
    .global _int4vec
    .global _int5vec
    .global _int6vec
    .global _int7vec

	.text

.include "vectable.inc"

.equ		UART_RXBUF,		0x200100
.equ		UART_TXBUF,		0x200100
.equ		UART_INTEN,		0x200101
.equ		UART_INTID,		0x200102
.equ		UART_FIFOCTRL,	0x200102
.equ		UART_LINECTRL,	0x200103
.equ		UART_MODEMCTRL,	0x200104
.equ		UART_LINESTAT,	0x200105
.equ		UART_MODEMSTAT, 0x200106
.equ		UART_DIVLAT1,	0x200100 /*clk div lsb, muss zuletzt geschrieben werden! */
.equ		UART_DIVLAT2,	0x200101 /* clk div msb */

.equ		UART_DIVVAL1,   27 /* 50 MHz / (16*115200) = 27,13 */
.equ		UART_DIVVAL2,	0

            .org 0x400
_start:

            move.w #0x2700, %SR
            
            jsr uart_init

            nop

            /* enable all m68k interrupts */
            andi.w #0xF0FF, %SR

            move.b #'A', UART_TXBUF

loop:

			jmp loop
    
uart_init:	
			/* enable access to divisor registers */
			move.b #0x80, UART_LINECTRL 
			/* setup 115200 baud (for 50mhz uart clk) */
			move.b #UART_DIVVAL2, UART_DIVLAT2
			move.b #UART_DIVVAL1, UART_DIVLAT1
			/* enable access to rx/tx buffers */
			move.b #0x07, UART_LINECTRL /*8bit chars and 2 stop bits*/
            move.b #3, UART_INTEN /* enable rx, tx interrupt*/
            
            /*move.b #'A', UART_TXBUF*/
            rts


_int1vec:   rte
_int2vec:   rte
_int3vec:   rte
_int4vec:   rte
_int5vec:   rte
_int6vec:   rte
_int7vec:   rte

