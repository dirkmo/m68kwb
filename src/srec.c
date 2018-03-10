#include "regmap.h"

typedef unsigned char uint8_t;
typedef unsigned long uint32_t;

uint32_t userprog_address;

uint8_t readchar() {
    while( (UART_LINESTAT & UART_LINESTAT_DR) == 0 );
    return UART_RXBUF;
}

void writechar( uint8_t c ) {
    while( (UART_LINESTAT & UART_LINESTAT_FE) == 0 );
    UART_TXBUF = c;
}

void uart_flush(void) {
    while( (UART_LINESTAT & UART_LINESTAT_DR) ) {
        (void)UART_RXBUF;
    }
}

enum STATE {
    BYTECOUNT,
    ADDRESS,
    DATA,
    CHECKSUM,
};

int nibble( char n ) {
    n -= '0';
    if( n > 9 ) {
        n -= 'A' - '0' - 10;
    }
    return n;
}

int receive_line( int type ) {
    enum STATE state = BYTECOUNT;
    int bytecount = 0x100;
    uint32_t address = 0;
    uint8_t dat;
    uint8_t dat_chksum = 0;
    uint8_t *dp;

    int acount = ( type == 3 || type == 7 ) ? 4 :
             ( type == 2 || type == 8 ) ? 3 : 2;

    while( bytecount ) {
        dat = nibble( readchar() ) << 4;
        dat |= nibble( readchar() );
        dat_chksum += dat;
        bytecount--;
        switch(state) {
            case BYTECOUNT:
                bytecount = dat;
                state = ADDRESS;
                break;
            case ADDRESS:
                address = (address << 8) | dat;
                acount--;
                if( acount == 0 ) {
                    if( type > 6 ) {
                        userprog_address = address;
                    }
                    state = type > 3 ? CHECKSUM : DATA;
                }
                break;
            case DATA:
                // write data to memory, advance address
                dp = (uint8_t*)address++;
                *dp = dat;
                state = ( bytecount <= 1 ) ? CHECKSUM : DATA;
                break;
            case CHECKSUM:
                if( dat_chksum == 0xFF ) {
                    //writechar('K');
                    return 0;
                }
                goto error;
            default: ;
                goto error;
        }
    }
error:
    writechar('X');
    return -2;
}

void print(const char *str) {
    while(*str) {
        writechar(*str++);
    }
}

void printhex(uint32_t val, uint8_t hexdigits) {
    int i;
    for( i = 0; i < hexdigits; i++ ) {
        uint8_t n = (val >> ((hexdigits-i-1)*4)) & 0x0F;
        uint8_t c = n > 9 ? n + 'A' - 10 : n + '0';
        writechar(c);
    }
}

int main(void) {
    int type;
    print("srecord parser ready.\r\n(g)o  (a)ddress\r\n");
    uart_flush();
    while( 1 ) {
        char r = readchar();
        if( r == 'S' ) {
            type = readchar() - '0';
            if( type >= 0 && type < 10 ) {
                receive_line( type );
            }
        } else if( r == 'g' ) {
            print("Starting program at $");
            printhex(userprog_address, 8);
            print("...\r\n");
            void (*func)(int, char*[]) = (void*)userprog_address;
            func(0, (void*)0);
            print("srecord parser ready.\r\n(g)o  (a)ddress\r\n");
        } else if( r == 'a' ) {
            print("Address: $");
            printhex(userprog_address, 8);
            print("\r\n");
        }
    }
    return 0;
}
