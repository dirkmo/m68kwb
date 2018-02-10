    .global _start
    .global _int1vec
    .global _int2vec
    .global _int3vec
    .global _int4vec
    .global _int5vec
    .global _int6vec
    .global _int7vec

	.text

.include "vectable.inc"

.equ		GPIO_IN,    0x200000
.equ		GPIO_OUT,   0x200004
.equ		GPIO_OE,    0x200008
.equ        GPIO_INTE,  0x20000C
.equ        GPIO_PTRIG, 0x200010
.equ        GPIO_CTRL,  0x200018

.equ        INTCTRL_VECTOR0, 0x200200
.equ        INTCTRL_VECTOR1, 0x200201
.equ        INTCTRL_VECTOR2, 0x200202
.equ        INTCTRL_VECTOR3, 0x200203
.equ        INTCTRL_VECTOR4, 0x200204
.equ        INTCTRL_VECTOR5, 0x200205
.equ        INTCTRL_VECTOR6, 0x200206

.equ        INTCTRL_IER,  0x200207

.equ        INTCTRL_IRQ0, 0x200208
.equ        INTCTRL_IRQ1, 0x200209
.equ        INTCTRL_IRQ2, 0x20020a
.equ        INTCTRL_IRQ3, 0x20020b
.equ        INTCTRL_IRQ4, 0x20020c
.equ        INTCTRL_IRQ5, 0x20020d
.equ        INTCTRL_IRQ6, 0x20020e

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
            /* value to be put on data bus */
            /*interessiert nicht, denn TG68k macht Autovektoren*/
            /*
            move.b #0, INTCTRL_VECTOR0
            move.b #0, INTCTRL_VECTOR1
            move.b #0, INTCTRL_VECTOR2
            move.b #0, INTCTRL_VECTOR3
            move.b #0, INTCTRL_VECTOR4
            move.b #0, INTCTRL_VECTOR5
            move.b #0, INTCTRL_VECTOR6
            */

            move.b #0xFF, INTCTRL_IER

            /* use int vector #1..7 = 0x0064..0x007C*/
            move.b #6, INTCTRL_IRQ0 /* ipl value to use for this int */
            move.b #2, INTCTRL_IRQ1
            move.b #6, INTCTRL_IRQ2
            move.b #6, INTCTRL_IRQ3
            move.b #6, INTCTRL_IRQ4
            move.b #6, INTCTRL_IRQ5
            move.b #6, INTCTRL_IRQ6

            /* enable all m68k interrupts */
            andi.w #0xF0FF, %SR
            
            jsr uart_init
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

