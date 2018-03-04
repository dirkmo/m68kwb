basic68k.run: basic68k.inc basic68k.asm
	vasmm68k_mot -quiet -m68000 -Fsrec -s19 -L basic68k.lst -o basic68k.run basic68k.asm

	#/opt/srecord/bin/srec_cat basic68k.run -Output ehbasic.hex -Ascii_Hex 

upload: basic68k.run
	stty -F /dev/ttyUSB0 raw 115200
	cat basic68k.run > /dev/ttyUSB0
	# set program entry adress $2000
	echo "S9032000DC" > /dev/ttyUSB0

clean:
	$(RM) basic68k.run basic68k.lst


# 	#srec_cat basic68k.run -fill 0x00 0x800 0x3fff --crop 0x0800 0x3fff -Output_Block_Size 16 -o temp
