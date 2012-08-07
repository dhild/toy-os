#include "kprintf.h"
#include "string.h"
#include "kdebug.h"

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
  char hex_string[19];
  hex_string[0] = '0';
  hex_string[1] = 'x';
  hex_string[18] = NULL;

  qword shift = 64;
    
  for ( int i = 0; i < 16; i++ ) {
    shift -= 4;
    char c = (value >> shift) & 0xF;

    switch (c) {
    case 15: {
      hex_string[2+i] = 'F';
      break;
    }
    case 14: {
      hex_string[2+i] = 'E';
      break;
    }
    case 13: {
      hex_string[2+i] = 'D';
      break;
    }
    case 12: {
      hex_string[2+i] = 'C';
      break;
    }
    case 11: {
      hex_string[2+i] = 'B';
      break;
    }
    case 10: {
      hex_string[2+i] = 'A';
      break;
    }
    default: {
      hex_string[2+i] = '0';
      hex_string[2+i] += (unsigned char)c;
      break;
    }
    } // switch(c)
  }
  kbreak();
  print_string( hex_string );
}

void print_string( const char* str ) {
  qword offset = 0;

  while ( str[offset] != NULL )
    print_char( str[offset++] );
}
