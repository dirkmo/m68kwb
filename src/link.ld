/* Bootstrap program linker script */

ENTRY(_start)

MEMORY
{
	rom (rx) : ORIGIN = 0x0, LENGTH = 0x1000
	ram (rwx) : ORIGIN = 0x1000, LENGTH = 0x100000 - 0x1000
}

SECTIONS
{
	.vectors :
	{
		KEEP(*(.vectors ))
	} > rom

	.text :
	{
		. = ALIGN(0x4);
		*(.text .text.*)
		_etext = .;
	} > rom

	.data :
	{
		. = ALIGN(0x4);
		*(.rodata .rodata.*)
		*(.data .data.*)
		_edata = .;
	} > rom

	.bss :
	{
		. = ALIGN(0x4);
		__bss_start = . ;
		*(.shbss)
		*(.bss .bss.*)
		*(COMMON)
		. = . + 4;
		__bss_end = ALIGN (0x8);
	} > ram

}
