/* 
 * File:   string.h
 * Author: D. Ryan Hild
 *
 * Created on May 30, 2010, 10:58 AM
 */

#ifndef _STRING_H
#define	_STRING_H

#include "types.h"

#ifdef	__cplusplus
extern "C" {
#endif

qword strlen( const char* s );

char* strcpy( char* dest, const char* src );

void* memcpy ( void* dest, const void * src, qword num );

#ifdef	__cplusplus
}
#endif

#endif	/* _STRING_H */

