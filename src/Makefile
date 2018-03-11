INCS = -I.
LIBS = -L/opt/m68k/lib/gcc/m68k-none-elf/7.3.0/m68000
CFLAGS = -m68000 -os -fomit-frame-pointer -fno-builtin -Wall -g

AS=/opt/m68k/bin/m68k-none-elf-as
CC=/opt/m68k/bin/m68k-none-elf-gcc
LD=/opt/m68k/bin/m68k-none-elf-ld
OBJCOPY=/opt/m68k/bin/m68k-none-elf-objcopy

SERIAL=/dev/ttyUSB0

WHAT_TO_PROG=srec

srec: srec.o crt0.o
	$(LD) $(LIBS) -Map=srec.map -nostartfiles -T link2.ld crt0.o srec.o -o srec
	$(OBJCOPY) -O binary -S srec srec.bin

crt0.o: crt0.s
	$(AS) $(AFLAGS) crt0.s -o crt0.o

%.o: %.c
	$(CC) $(CFLAGS) $(INCS) -c $< -o $@
	
clean:
	rm -f srec.o crt0.o srec srec.bin test.bin test


test: test.o crt0.o
	m68k-none-elf-gcc test.c -o test -T /opt/m68k/m68k-none-elf/lib/m68kwb.ld -m68000 -Xlinker -Map=test.map
	$(OBJCOPY) -O binary -S test test.bin
	$(OBJCOPY) -O srec -S test test.bin


prog: $(WHAT_TO_PROG)
	stty -F $(SERIAL) raw 115200
	xxd -u -p $(WHAT_TO_PROG).bin | tr -d '\n' > $(SERIAL)
	echo '*' > $(SERIAL)
