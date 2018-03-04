    .global _start

stack:		.4byte 0x2000
reset:		.4byte _start

	.text

.include "regmap.inc"

_start:

            /* setup gpio */
			move.l #0xFF, GPIO_OE
			move.l #0xAA, GPIO_OUT

            /* print success message */
            lea msg, %a0
            jsr printstr

loop:
			jmp loop
   
/* printstr function:
   expects address of null terminated string in reg a0 */
printstr:   move.b (%a0)+, %d0
            beq .done
1:          btst.b #5, UART_LINESTAT
            beq 1b
            move.b %d0, UART_TXBUF
            bra printstr
.done:      rts

/* send byte in d0 */
putchar:
1:          btst.b #5, UART_LINESTAT
            beq 1b
            move.b %d0, UART_TXBUF
            rts

            .data
msg:        .asciz "Bootstrap successful." 
