    .global _start

	.section .vectors,"a"
stack:		.4byte 0x2000
reset:		.4byte _start

	.text

_start:
            move.w #0xABCD, 0x100001
            move.w #0x1B1D, 0x100006
            move.w #0xEF45, 0x100011

loop:
			jmp loop
    
