    .global _start

	.section .vectors,"a"
stack:		.4byte 0x2000
reset:		.4byte _start

	.text

.equ		GPIO_IN,  0x100000
.equ		GPIO_OUT, 0x100004
.equ		GPIO_OE,  0x100008

_start:
			move.l #0x000000FF, GPIO_OE
			move.l #0x000000FF, GPIO_OUT
loop:
			move.l #0x00000001, GPIO_OUT
			move.l #0x00000002, GPIO_OUT
			move.l #0x00000004, GPIO_OUT
			move.l #0x00000008, GPIO_OUT
			move.l #0x00000010, GPIO_OUT
			move.l #0x00000020, GPIO_OUT
			move.l #0x00000040, GPIO_OUT
			move.l #0x00000080, GPIO_OUT

			jmp loop
    
