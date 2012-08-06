/* 
 * File:   main.h
 * Author: D. Ryan Hild
 *
 * Created on May 24, 2010, 8:25 PM
 */

#ifndef _MAIN_H
#define	_MAIN_H

#include "multiboot.h"
#include "types.h"

extern "C" void boot(struct mb_header *header, qword magic);

extern "C" void kmain();

#endif	/* _MAIN_H */

