.include "regmap.inc"
.global _start
.text

stack:	.4byte 0x100000
reset:  .4byte _start

.extern __bss_start
.extern __bss_end

_start:
/*
			moveal #0, %a6
			moveal #0, %a5
			moveal #0, %a4
			moveal #0, %a3
			moveal #0, %a2

			movel #0, %d7
			movel #0, %d6
			movel #0, %d5
			movel #0, %d4
			movel #0, %d3
			movel #0, %d2
			movel #0, %d1
			movel #0, %d0
*/			
			#clear bss
			moveal	#__bss_start, %a0
			moveal	#__bss_end, %a1
		1:
			move.l	#0, (%a0)+
			cmpal	%a0, %a1
			bne	1b
			
			jsr main

			lea main_exited_msg, %a0
			jsr printstr

loop:		bra loop

/* printstr function:
   expects address of null terminated string in reg a0 */
printstr:   move.b (%a0)+, %d0
            beq .done
            bsr putchar
            bra printstr
.done:      rts

/* send byte in d0 */
putchar:
            btst.b #5, UART_LINESTAT
            beq putchar
            move.b %d0, UART_TXBUF
            rts


	.data
main_exited_msg: .asciz "main exited."