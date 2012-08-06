/* 
 * File:   io.h
 * Author: D. Ryan Hild
 *
 * Created on May 25, 2010, 12:40 AM
 */

#ifndef _IO_H
#define	_IO_H

#include "types.h"

#ifdef	__cplusplus
extern "C" {
#endif

    byte inb( const byte port );

    void outb( const byte output, const byte port );

#ifdef	__cplusplus
}
#endif

#endif	/* _IO_H */

