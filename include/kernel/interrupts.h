#ifndef KERNEL_INTERRUPTS_H
#define KERNEL_INTERRUPTS_H

#include <kernel/stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

  typedef struct {
    uint64_t rax, rbx, rcx, rdx;
    uint64_t rsp, rbp, rsi, rdi;
    uint64_t r8, r9, r10, r11;
    uint64_t r12, r13, r14, r15;
    uint64_t rflags;
    uint64_t rip;
    uint64_t cr2;
    uint16_t cs, ds, ss, es, fs, gs;
  } __attribute__((packed)) interrupt_regs;

  typedef void (*interrupt_handler)(uint64_t, interrupt_regs*);

  extern interrupt_handler interrupts[256];

  int handle_exception(void* rip);

#ifdef __cplusplus
}
#endif

#endif /* INTERRUPTS_H */
