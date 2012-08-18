/* 
 * File:   kprintf.h
 * Author: D. Ryan Hild
 *
 * Created on May 30, 2010, 9:08 AM
 */

#ifndef _KPRINTF_H
#define	_KPRINTF_H

#include "types.h"

#ifdef __cplusplus
extern "C" {
#endif
  // These functions are implemented in assembly.
  // See printing.asm
  void print_char( const char c );
  void print_string( const char* s );
#ifdef __cplusplus
}
#endif

void print_dec( qword value );
void print_hex( qword value );
void log_error( const char* s );

#endif	/* _KPRINTF_H */

