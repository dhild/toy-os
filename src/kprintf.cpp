#include "kprintf.h"
#include "string.h"
#include "kdebug.h"

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
      hex_string[2+i] += (char)c;
      break;
    }
    } // switch(c)
  }
  kbreak();
  print_string( hex_string );
}
