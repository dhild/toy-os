/* 
 * File:   gdb.h
 * Author: D. Ryan Hild
 *
 * Created on May 31, 2010, 6:01 PM
 */

#ifndef _GDB_H
#define	_GDB_H

#ifdef	__cplusplus
extern "C" {
#endif

#ifdef DEBUG
void set_debug_traps();
void breakpoint();
#else
inline void set_debug_traps() {}
inline void breakpoint() {}
#endif

#ifdef	__cplusplus
}
#endif

#endif	/* _GDB_H */

