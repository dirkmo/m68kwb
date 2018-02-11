    .global _start

	.text

stack:		.4byte 0x100400
reset:		.4byte _start

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
.equ        INTCTRL_VECTOR7, 0x200207

.equ        INTCTRL_IER,  0x200207

.equ        INTCTRL_IRQ0, 0x200208
.equ        INTCTRL_IRQ1, 0x200209
.equ        INTCTRL_IRQ2, 0x20020a
.equ        INTCTRL_IRQ3, 0x20020b
.equ        INTCTRL_IRQ4, 0x20020c
.equ        INTCTRL_IRQ5, 0x20020d
.equ        INTCTRL_IRQ6, 0x20020d
.equ        INTCTRL_IRQ7, 0x20020e


_start:
            move.b #1, INTCTRL_VECTOR0
            move.w #1, INTCTRL_VECTOR0
            move.l #1, INTCTRL_VECTOR0
loop:

			jmp loop
    
