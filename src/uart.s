    .global _start

.include "regmap.inc"

	.text
stack:		.4byte 0x100400
reset:		.4byte _start

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

			move.l #0xFF, GPIO_OE
			move.l #0x00, GPIO_OUT

uart_init:	
			/* enable access to divisor registers */
			move.b #0x80, UART_LINECTRL 
			/* setup 115200 baud (for 50mhz uart clk) */
			move.b #UART_DIVVAL2, UART_DIVLAT2
			move.b #UART_DIVVAL1, UART_DIVLAT1
			/* enable access to rx/tx buffers */
			move.b #0x07, UART_LINECTRL /*8bit chars and 2 stop bits*/
            
            move.b #'A', UART_TXBUF

            move.b UART_LINECTRL, %d0
            move.l %d0, GPIO_OUT


wait:       

            btst.b #0, UART_LINESTAT
            beq wait
            move.b UART_RXBUF, %d0

            move.l %d0, GPIO_OUT
            addi.b #1, %d0
            move.b %d0, UART_TXBUF
            
            jmp wait


loop:       jmp loop


/*
			jsr hello
loop:
			jmp loop

hello:		movea.l	#msg, %a0
l:			move.b (%a0)+, %d0
			tst.b %d0
			beq.s loop
			move.b %d0, UART_TXBUF
			bra.s l
			rts

.data
msg:		.asciz "Hallo Welt!\n"
*/

