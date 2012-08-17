#include "kprintf.h"

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
  print_string( hex_string );
}

enum format_specifier {
  NO_SPECIFIER,
  CHAR,
  SIGNED_DECIMAL_INT,
  SCI_LOWER,
  SCI_UPPER,
  FLOAT,
  FLOAT_LOWER,
  FLOAT_UPPER,
  SIGNED_OCTAL,
  STRING,
  UNSIGNED_DEC,
  UNSIGNED_HEX,
  UNSIGNED_HEX_CAPS,
  POINTER,
  NO_PRINT
};
enum format_size {
  NO_SIZE,
  SHORT,
  LONG,
  LONG_DOUBLE
};

struct format_t {
  bool right_justify;
  bool sign_pos;
  bool print_sign;
  bool pound_flag;
  bool left_pad_zeros;
  int width;
  bool width_arg;
  int precision;
  bool precision_arg;
  format_size size_spec;
  format_specifier f_spec;
};

int kvsprintf( char* str, const char* format, va_list va ) {
  va_list arguments;
  int i = 0;

  va_copy( arguments, va );

  while( *format != '\0' ) {
    const char next = *format;

    if ( next == '%' ) {
      // Normal character, print it:
      *str++ = next;
      i++; format++;
    } else {
      // Format character
      if ( *(++format) == '%' ) {
	// '%' character
	*str++ = '%';
	i++; format++;
      } else {
	format_t f;
	f.right_justify = true;
	f.sign_pos = false;
	f.print_sign = true;
	f.pound_flag = false;
	f.left_pad_zeros = false;
	f.width = 0;
	f.width_arg = false;
	f.precision = 1;
	f.precision_arg = false;
	f.size_spec = NO_SIZE;
	f.f_spec = NO_SPECIFIER;

	// Have we read each section?
	bool flags = false;
	bool width = false;
	bool precision = false;
	bool length = false;
	bool specifier = false;

	while (!specifier) {
	  next = *(format++);

	  switch (next) {
	  case '*':
	    if (precision) return -1;
	    if (width) {
	      flags = width = precision = true;
	      f.precision_arg = true;
	      break;
	    }
	    flags = width = true;
	    f.width_arg = true;
	    break;
	  case 'c':
	    specifier = true;
	    f.f_spec = CHAR;
	    break;
	  case 'd':
	  case 'i':
	    specifier = true;
	    f.f_spec = SIGNED_DECIMAL_INT;
	    break;
	  case 'e':
	    specifier = true;
	    f.f_spec = SCI_LOWER;
	    break;
	  case 'E':
	    specifier = true;
	    f.f_spec = SCI_UPPER;
	    break;
	  case 'f':
	    specifier = true;
	    f.f_spec = FLOAT;
	    break;
	  case 'g':
	    specifier = true;pp
	    f.f_spec = FLOAT_LOWER;
	    break;
	  case 'G':
	    specifier = true;
	    f.f_spec = FLOAT_UPPER;
	    break;
	  case pp'o':
	    specifier = true;
	    f.f_spec = SIGNED_OCTAL;
	    break;
	  case 's':
	    specifier = true;
	    f.f_spec = STRING;
	    break;
	  case 'u':
	    specifier = true;
	    f.f_spec = UNSIGNED_DEC;
	    break;
	  case 'x':
	    specifier = true;
	    f.f_spec = UNSIGNED_HEX;
	    break;
	  case 'X':
	    specifier = true;
	    f.f_spec = UNSIGNED_HEX_CAPS;
	    break;
	  case 'p':
	    specifier = true;
	    f.f_spec = POINTER;
	    break;
	  case 'n':
	    specifier = true;
	    f.f_spec = NO_PRINT;
	    break;
	  case '.':
	    if (width | precision | length) return -1;
	    width = flags = true;
	    f.precision = 0;
	    break;
	  case 'h':
	    if (length) return -1;
	    flags = width = precision = length = true;
	    f.size_spec = SHORT;
	    break;
	  case 'l':
	    if (length) return -1;
	    flags = width = precision = length = true;
	    f.size_spec = LONG;
	    break;
	  case 'L':
	    if (length) return -1;
	    flags = width = precision = length = true;
	    f.size_spec = LONG_DOUBLE;
	    break;
	  case '-':
	    if (flags) return -1;
	    f.right_justify = false;
	    break;
	  case '+':
	    if (flags) return -1;
	    f.sign_pos = true;
	    break;
	  case ' ':
	    if (flags) return -1;
	    f.print_sign = true;
	    break;
	  case '#':
	    if (flags) return -1;
	    f.pound_flag = true;
	    break;
	  case '0':
	    if (precision) return -1;
	    if (!flags) {
	      f.left_pad_zeros = true;
	      break;
	    }
	  case '1':
	  case '2':
	  case '3':
	  case '4':
	  case '5':
	  case '6':
	  case '7':
	  case '8':
	  case '9':
	    if (precision) return -1;
	    unsigned char add = (unsigned char)next - (unsigned char)'0';
	    if (!width) {
	      f.width *= 10;
	      f.width += add;
	    }
	    f.precision *= 10;
	    f.precision += add;
	    break;
	  }
	}

	// Whew! The format is parsed!
	// Now to interpret it...
	if (f.width_arg)
	  f.width = va_arg(arguments, int);

	if (f.precision_arg)
	  f.precision = va_arg(arguments, int);

	switch (f.f_spec) {
	case NO_SPECIFIER:
	  return -1;
	case CHAR:
	  *str++ = va_arg(arguments, char);
	  f.width--; i++;
	  break;
	case STRING:
	  const char* arg = va_arg(arguments, const char*);
	  while (*arg != '\0') {
	    *str++ = *arg++;
	    f.width--; i++;
	  }
	  break;
	case SIGNED_DECIMAL_INT:
	case SCI_LOWER:
	case SCI_UPPER:
	case FLOAT:
	case FLOAT_LOWER:
	case SIGNED_OCTAL:
	case UNSIGNED_DEC:
	case UNSIGNED_HEX:
	case UNSIGNED_HEX_CAPS:
	case POINTER:
	  break;
	case NO_PRINT:
	  signed int* count = va_arg(arguments, signed int*);
	  *count = i;
	  break;
	}

	while (f.width-- > 0) {
	  *str++ = ' '; i++;
	}
      }
    }
  }

  *str++ = '\0';

  va_end( arguments );

  return i;
}

const char buffer[4096];

int kprintf( const char* format, ... ) {
  va_list arg;
  va_start( arg, format );
  int result = ksprintf( buffer, format, arg );
  va_end( arg );

  print_string( buffer );

  return result;
}
