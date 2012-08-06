#include "gdb.h"
#include "io.h"

#define com1 0x3f8
#define com2 0x2f8

#define combase com1

#define byte unsigned char

void init_serial(void)
{
    outb((byte)(inb((byte)(combase + 3)) | 0x80), (byte)(combase + 3));
    outb((byte)12, (byte)combase);                           /* 9600 bps, 8-N-1 */
    outb((byte)0, (byte)(combase+1));
    outb((byte)(inb((byte)(combase + 3)) & 0x7f), (byte)(combase + 3));
}

int getDebugChar(void)
{
    while (!(inb((byte)(combase + 5)) & 0x01));
    return inb((byte)combase);
}

void putDebugChar(int ch)
{
    while (!(inb((byte)(combase + 5)) & 0x20));
    outb((byte) ch, (byte)combase);
}

void flush_i_cache(void)
{
   __asm__ __volatile__ ("jmp 1f\n1:");
}
