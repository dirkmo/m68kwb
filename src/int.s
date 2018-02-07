    .global _start

	.section .vectors,"a"
stack:		.4byte 0x2000
reset:		.4byte _start

	.text

.equ		GPIO_IN,    0x200000
.equ		GPIO_OUT,   0x200004
.equ		GPIO_OE,    0x200008
.equ        GPIO_INTE,  0x20000C
.equ        GPIO_PTRIG, 0x200010
.equ        GPIO_CTRL,  0x200018

_start:
			move.l #0x000000FE, GPIO_OE
			move.l #0x00000000, GPIO_OUT

            move.l #1, GPIO_INTE /* enable int for io0 */
            move.l #1, GPIO_PTRIG /* trigger on pos edge */
            move.l #1, GPIO_CTRL /* enable interrupt on gpio, clear pending ints */

			move.l #0x00000000, GPIO_OUT

            /* enable m68k interrupts */
            andi.w #0, %SR
            
            /* trigger interrupt (io1 should be connected to io0) */
            move.l #2, GPIO_OUT
loop:

			jmp loop
    
