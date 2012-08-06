/* 
 * File:   memalloc.h
 * Author: D. Ryan Hild
 *
 * Created on June 9, 2010, 2:16 PM
 */

#ifndef _MEMALLOC_H
#define	_MEMALLOC_H

#include "types.h"

#ifdef	__cplusplus
extern "C" {
#endif

    void setup_memory( void* start, qword length );

    void* allocate( qword length );

    void free( void* mem );

#ifdef	__cplusplus
}
#endif

#endif	/* _MEMALLOC_H */

