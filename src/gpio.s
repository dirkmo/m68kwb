    .global _start

	.section .vectors,"a"
stack:		.4byte 0x100400
reset:		.4byte _start

	.text

.include "regmap.inc"

_start:
			move.l #0x000000FF, GPIO_OE
			move.l #0x000000FF, GPIO_OUT

			move.l #0x00000002, GPIO_OUT
            move.l #0xAE, %d0

loop:
            move.l GPIO_OUT, %d0
            rol.b #1, %d0
            move.l %d0, GPIO_OUT

			jmp loop
    
