    .global _start
    .global __ram_end

	.text

.include "regmap.inc"

stack:		.4byte __ram_end
reset:		.4byte _start


_start:

            move.b #1, SDSPI_CMD 
            move.w #1, SDSPI_CMD 
            move.l #1, SDSPI_CMD 

            move.b SDSPI_CMD, %d0
            move.w SDSPI_CMD, %d0
            move.l SDSPI_CMD, %d0

ende:       jmp ende
