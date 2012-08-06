/* 
 * File:   kprintf.h
 * Author: D. Ryan Hild
 *
 * Created on May 30, 2010, 9:08 AM
 */

#ifndef _KPRINTF_H
#define	_KPRINTF_H

#include "types.h"

#ifdef	__cplusplus
extern "C" {
#endif

    void setup_printing( dword vbe_control_info,
                         dword vbe_mode_info,
                         dword vbe_mode,
                         dword vbe_interface_seg,
                         dword vbe_interface_off,
                         dword vbe_interface_len );

    void print_char( const char c );
    void print_dec( qword value );
    void print_hex( qword value );
    void print_string( const char* str );
    void print_special( const char* str, void* special );


#ifdef	__cplusplus
}
#endif

#endif	/* _KPRINTF_H */

