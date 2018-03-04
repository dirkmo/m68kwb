    .global _start

.equ        FREQ, 50000000
.equ        BAUDRATE, 115200

.equ		UART_DIVVAL, FREQ / (16*BAUDRATE)
.equ        UART_DIVVAL1, UART_DIVVAL & 0xFF
.equ		UART_DIVVAL2,(UART_DIVVAL >> 8) & 0xFF
.equ        TOPOFRAM, 0x100000

	.text

.include "regmap.inc"

stack:		.4byte TOPOFRAM
reset:		.4byte _start


_start:
            /* setup gpio */
			move.l #0xFF, GPIO_OE
			move.l #0x00, GPIO_OUT

            /* setup uart */
			/* enable access to divisor registers */
			move.b #0x80, UART_LINECTRL 
			/* setup 115200 baud (for 50mhz uart clk) */
			move.b #UART_DIVVAL2, UART_DIVLAT2
			move.b #UART_DIVVAL1, UART_DIVLAT1
			/* enable access to rx/tx buffers */
			move.b #0x07, UART_LINECTRL /*8bit chars and 2 stop bits*/

            /* print boot message */
            lea msg, %a0
            jsr printstr


            movea.l #0, %a0
.recloop:
            jsr receive_byte
            move.b %d0, (%a0)+
            /*jsr printhex*/
            eori.l #0x80, GPIO_OUT
            bra .recloop


/* receive two ascii hex digits and convert them into a char */
receive_byte:
            /* receive upper nibble */
            jsr getchar
            cmpi.b #'*', %d0
            beq boot
            jsr .receive_nibble
            move.b %d0, %d2
            lsl.b #4, %d2
            /* receive lower nibble */
            jsr getchar
            cmpi.b #'*', %d0
            jsr .receive_nibble
            cmpi.b #'*', %d0
            beq boot
            or.b %d0, %d2
            move.b %d2, %d0
            rts

.receive_nibble:
            subi.b #'0', %d0
            cmpi.b #9, %d0
            ble 1f /* branch if less or equal 9*/
            subi.b #7, %d0
1:          rts


boot:
            lea boot_msg, %a0
            jsr printstr
            move.l #0x80, GPIO_OUT
            move.b #3, BOOTCTRL_CTRL /* RAM enable and reset cpu */


halt:       /* should never get here */
            lea halt_msg, %a0
            jsr printstr
            jmp halt

            
/* print char in d0 as hex */
printhex:
            jsr char2hex
            /* d1.w now holds hexnumber */
            move.w %d1, %d0
            lsr.w #8, %d0
            jsr putchar
            move.b %d1, %d0
            jsr putchar
            rts

/* convert char in d0.b to ascii hexnumber in d1.w */
char2hex:
            /* convert upper nibble*/
            move.b %d0, %d1
            lsr.b #4, %d1
            andi.l #0xF, %d1
            cmpi.b #0xA, %d1
            blt 1f /* skip if 0..9 */
            /* A..F */
            addi.b #7, %d1
1:          addi.b #48, %d1
            lsl #8, %d1
            /* convert lower nibble */
            andi.l #0xF, %d0
            cmpi.b #0xA, %d0
            blt 2f /* skip if 0..9 */
            /* A..F */
            addi.b #7, %d0
2:          addi.b #48, %d0
            move.b %d0, %d1
            rts

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

/* block until byte received into d0 */
getchar:
            btst.b #0, UART_LINESTAT
            beq getchar
            move.b UART_RXBUF, %d0
            rts


            .data
msg:        .asciz "m68k Computer bootstrap program.\r\n"
halt_msg:   .asciz "Halt.\r\n"
boot_msg:   .asciz "boot.\r\n"

/* vim: set ft=asm68k : */
