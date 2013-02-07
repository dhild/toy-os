#ifndef KERNEL_INTERRUPTS_H
#define KERNEL_INTERRUPTS_H

/* Intel defined processor interrupts.
 * These are hard-coded and cannot be changed.
 */
#define DE_VECTOR 0x00
#define DB_VECTOR 0x01
#define NMI_VECTOR 0x02
#define BP_VECTOR 0x03
#define OF_VECTOR 0x04
#define BR_VECTOR 0x05
#define UD_VECTOR 0x06
#define NM_VECTOR 0x07
#define DF_VECTOR 0x08
#define COP_VECTOR 0x09
#define TS_VECTOR 0x0A
#define NP_VECTOR 0x0B
#define SS_VECTOR 0x0C
#define GP_VECTOR 0x0D
#define PF_VECTOR 0x0E
#define MF_VECTOR 0x10
#define AC_VECTOR 0x11
#define MC_VECTOR 0x12
#define XM_VECTOR 0x13

/* Intel manual states that vectors 32-255 are user-defined. */

/*
 * Following the linux lead, we'll set the IRQ vectors to be
 * vectors 32-48.
 */
#define IRQ0_VECTOR 0x20
#define IRQ1_VECTOR (IRQ0_VECTOR + 1)
#define IRQ2_VECTOR (IRQ0_VECTOR + 2)
#define IRQ3_VECTOR (IRQ0_VECTOR + 3)
#define IRQ4_VECTOR (IRQ0_VECTOR + 4)
#define IRQ5_VECTOR (IRQ0_VECTOR + 5)
#define IRQ6_VECTOR (IRQ0_VECTOR + 6)
#define IRQ7_VECTOR (IRQ0_VECTOR + 7)
#define IRQ8_VECTOR (IRQ0_VECTOR + 8)
#define IRQ9_VECTOR (IRQ0_VECTOR + 9)
#define IRQ10_VECTOR (IRQ0_VECTOR + 10)
#define IRQ11_VECTOR (IRQ0_VECTOR + 11)
#define IRQ12_VECTOR (IRQ0_VECTOR + 12)
#define IRQ13_VECTOR (IRQ0_VECTOR + 13)
#define IRQ14_VECTOR (IRQ0_VECTOR + 14)
#define IRQ15_VECTOR (IRQ0_VECTOR + 15)

/*
 * We'll use 64 for the syscall interface.
 */
#define SYSCALL_VECTOR 0x40

/* Now for some APIC vectors. These are organized by priority. */
#define APIC_TIMER_VECTOR    0xef
#define APIC_LINT0_VECTOR    0xf0
#define APIC_LINT1_VECTOR    0xf1
#define APIC_PERF_MON_VECTOR 0xf2
#define APIC_THERMAL_VECTOR  0xfa
#define APIC_ERROR_VECTOR    0xfe
#define SPURIOUS_APIC_VECTOR 0xff

#endif /* INTERRUPTS_H */
