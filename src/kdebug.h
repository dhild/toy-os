#ifndef _KDEBUG_H_
#define _KDEBUG_H_

// BOCHS "magic" breakpoint code
#define kbreak() asm("xchg %bx,%bx")

#endif // _KDEBUG_H_
