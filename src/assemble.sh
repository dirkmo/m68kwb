#!/bin/bash

name=$(basename $1 .s)

if [ ! -e $1 ]; then
    echo "Datei $1 existiert nicht."
    exit 1
fi
echo "Assembliere $1..."
if ! m68k-elf-as $name.s -o $name.o ; then exit 2 ; fi
if ! m68k-elf-ld $name.o -nostartfiles -T link.ld -o $name ; then exit 3 ; fi
if ! m68k-elf-objcopy -O binary -S $name $name.bin ; then exit 4 ; fi
echo "Binary $name.bin erzeugt"
if ../host/bin2verilog $name.bin 32 > $name.v; then echo "Verilogfile $name.v erzeugt"; fi
# Signal umbenennen
sed -i 's/boot_read/rom_data_o/' $name.v
