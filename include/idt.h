/* 
 * File:   idt.h
 * Author: D. Ryan Hild
 *
 * Created on May 29, 2010, 8:59 PM
 */

#ifndef _IDT_H
#define	_IDT_H

#include "types.h"
#include "interrupts.h"

#ifdef	__cplusplus
extern "C" {
#endif

void setup_interrupts();

#ifdef	__cplusplus
}
#endif

#endif	/* _IDT_H */

