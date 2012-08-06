#include "kprintf.h"
#include "string.h"

bool setup = false;

byte attribute = 0x2a;
qword tabsize = 4;

qword offset;
byte* base;

qword width;
qword height;
qword size;

void setup_printing( dword vbe_control_info,
                     dword vbe_mode_info,
                     dword vbe_mode,
                     dword vbe_interface_seg,
                     dword vbe_interface_off,
                     dword vbe_interface_len ) {

    asm ( "xchg %bx,%bx" );
    
    if ( setup == true )
        return;

    setup = true;

    // If the multiboot flags are good, this SHOULD be non-zero, as it is
    // a physical address.....
    if ( vbe_control_info | vbe_mode_info | vbe_mode |
         vbe_interface_seg | vbe_interface_off | vbe_interface_len ) {

    } else {
        // Well crap. Assume that the video memory is at 0xB8000, and color
    }

    // As for now, we will simply assume color video at 0xB8000

    attribute = 0x2a;
    offset = 0;
    base = (byte*)(0xB8000);
    width = 80;
    height = 25;
    size = 2;
}

/** Scrolls one line.
 */
void scroll_print() {
    memcpy( base, base + (width * size), size*(width*(height-1)) );
    offset -= (width * size);
}

void print_char( const char c ) {
    if ( offset >= ( size * (width * height) ) ) {
        scroll_print();
    }
    switch( c ) {
        case '\n': {
            qword temp = offset / (width*size);
            temp++;
            offset = temp * (width*size);
            break;
        }
        case '\t': {
            qword temp = offset / (tabsize*size);
            temp++;
            offset = temp * (tabsize*size);
            break;
        }
        default: {
            base[offset++] = c;
            base[offset++] = attribute;
            break;
        }
    }
}

void print_dec( qword value ) {
    char characters[21];

    characters[20] = NULL;

    for ( int i = 19; i >= 0; i-- ) {
        if ( value > 0 ) {
            characters[i] = ('0' + (value % 10));
            value /= 10;
        } else {
            characters[i] = '0';
        }
    }

    print_string( characters );
}

void print_hex( qword value ) {
    print_char( '0' );
    print_char( 'x' );

    qword shift = 60;
    
    for ( int i = 0; i < 16; i++ ) {
        char c = (value >> shift) & 0xF;

        switch (c) {
            case 15: {
                print_char('F');
                break;
            }
            case 14: {
                print_char('E');
                break;
            }
            case 13: {
                print_char('D');
                break;
            }
            case 12: {
                print_char('C');
                break;
            }
            case 11: {
                print_char('B');
                break;
            }
            case 10: {
                print_char('A');
                break;
            }
            default: {
                print_char('0' + c);
                break;
            }
        }

        shift -= 4;
    }
}

void print_string( const char* str ) {
    qword offset = 0;

    while ( str[offset] != NULL )
        print_char( str[offset++] );
}

