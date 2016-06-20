#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char **argv) {
    if( argc < 2 ) {
        fprintf(stderr, "bin2verilog infile [bitwidth]\n");
        return 1;
    }
    FILE *datei = fopen( argv[1], "r" );
    if( datei == NULL ) {
        fprintf(stderr, "Datei nicht gefunden.\n");
        return 2;
    }

	int width = 16;

	if( argc == 3 ) {
		width = strtoul( argv[2], NULL, 10 );
	}
	if( width % 8 != 0 ) {
		fprintf( stderr, "Width not a multiple of 8\n" );
		return 3;
	}	

    uint32_t pos = 0;
    unsigned char vals[width/8];
	int read;
    while( 1 ) {
		memset( vals, 0, sizeof(vals) );
        read = fread( vals, 1, sizeof( vals ), datei );
		if( read < 1 ) {
			break;
		}
        printf("32'h%08X: boot_read[%d:0] = %d'h", pos, width-1, width);
		for( int i = 0; i < width/8; i++ ) {
			printf("%02X", vals[i] );
		}
		printf(";\n");
	
        pos += read;
    }
    return 0;
}
