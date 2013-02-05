#ifndef KERNEL_INTERRUPTS_H
#define KERNEL_INTERRUPTS_H

#include <config.h>

#ifdef __cplusplus
extern "C" {
#endif

  typedef struct {
    __u64 rax, rbx, rcx, rdx;
    __u64 rsp, rbp, rsi, rdi;
    __u64 r8, r9, r10, r11;
    __u64 r12, r13, r14, r15;
    __u64 rflags;
    __u64 rip;
    __u64 cr2;
    __u16 cs, ds, ss, es, fs, gs;
  } __attribute__((packed)) interrupt_regs;

  typedef void (*interrupt_handler)(__u64, interrupt_regs*);

  extern interrupt_handler interrupts[256];

  int handle_exception(void* rip);

#ifdef __cplusplus
}
#endif

#endif /* INTERRUPTS_H */
