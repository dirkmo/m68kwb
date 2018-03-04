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
.include regmap.s"

            .org 0x400
_start:

            /* mask all interrupts */
            move.w #0x2700, %SR
            
            move.w #0x3F, TIMER1_MOD
            move.w #0x0, TIMER1_CNT
            move.w #7, TIMER1_CTL


            /* enable all m68k interrupts */
            /*
            */
            andi.w #0xF0FF, %SR


loop:

			jmp loop
    

_int1vec:   rte
_int2vec:   rte

_int3vec:   
            move.w #0, TIMER1_CTL
            move.w #0, TIMER1_CNT
            move.w #7, TIMER1_CTL
            rte

_int4vec:   rte
_int5vec:   rte
_int6vec:   rte
_int7vec:   rte

