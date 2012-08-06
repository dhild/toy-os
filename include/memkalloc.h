/* 
 * File:   memkalloc.h
 * Author: D. Ryan Hild
 *
 * Created on June 9, 2010, 2:45 PM
 */

#ifndef _MEMKALLOC_H
#define	_MEMKALLOC_H

#include "memalloc.h"

#ifdef	__cplusplus
extern "C" {
#endif

    void setup_memory_sizes( dword lower, dword upper );
    void setup_memory_map( dword length, dword mem );

#ifdef	__cplusplus
}
#endif

#endif	/* _MEMKALLOC_H */

