#ifndef KERNEL_ASSEMBLY_H
#define KERNEL_ASSEMBLY_H

#include <kernel/stdint.h>

inline void cpuid(uint32_t id, uint32_t* eax, uint32_t* ebx, uint32_t* ecx, uint32_t* edx) {
  asm volatile ("cpuid" : "=a"(*eax), "=b"(*ebx), "=c"(*ecx), "=d"(*edx) : "a"(id));
}

inline void readMSR(uint32_t msr, uint32_t* low, uint32_t* high) {
  asm volatile ("rdmsr" : "=a"(*low), "=d"(*high) : "c"(msr));
}

inline void writeMSR(uint32_t msr, uint32_t low, uint32_t high) {
  asm volatile ("wrmsr" :: "a"(low), "d"(high), "c"(msr));
}

#define IA32_APIC_BASE_MSR       (0x1B)

#define X2APIC_LOCAL_ID_MSR      (0x802)
#define X2APIC_LOCAL_VERSION_MSR (0x803)
#define X2APIC_TPR_MSR           (0x808)
#define X2APIC_PPR_MSR           (0x80A)
#define X2APIC_EOI_MSR           (0x80B)
#define X2APIC_LDR_MSR           (0x80D)
#define X2APIC_SVR_MSR           (0x80F)
#define X2APIC_ISR_31_0_MSR      (0x810)
#define X2APIC_ISR_63_32_MSR     (0x811)
#define X2APIC_ISR_95_64_MSR     (0x812)
#define X2APIC_ISR_127_96_MSR    (0x813)
#define X2APIC_ISR_159_128_MSR   (0x814)
#define X2APIC_ISR_191_160_MSR   (0x815)
#define X2APIC_ISR_223_192_MSR   (0x816)
#define X2APIC_ISR_255_224_MSR   (0x817)
#define X2APIC_TMR_31_0_MSR      (0x818)
#define X2APIC_TMR_63_32_MSR     (0x819)
#define X2APIC_TMR_95_64_MSR     (0x81A)
#define X2APIC_TMR_127_96_MSR    (0x81B)
#define X2APIC_TMR_159_128_MSR   (0x81C)
#define X2APIC_TMR_191_160_MSR   (0x81D)
#define X2APIC_TMR_223_192_MSR   (0x81E)
#define X2APIC_TMR_255_224_MSR   (0x81F)
#define X2APIC_IRR_31_0_MSR      (0x820)
#define X2APIC_IRR_63_32_MSR     (0x821)
#define X2APIC_IRR_95_64_MSR     (0x822)
#define X2APIC_IRR_127_96_MSR    (0x823)
#define X2APIC_IRR_159_128_MSR   (0x824)
#define X2APIC_IRR_191_160_MSR   (0x825)
#define X2APIC_IRR_223_192_MSR   (0x826)
#define X2APIC_IRR_255_224_MSR   (0x827)
#define X2APIC_ESR_MSR           (0x828)
#define X2APIC_LVT_CMCI_MSR      (0x82F)
#define X2APIC_ICR_MSR           (0x830)
#define X2APIC_LVT_TIMER_MSR     (0x832)
#define X2APIC_LVT_THERMAL_MSR   (0x833)
#define X2APIC_LVT_PERF_MON_MSR  (0x834)
#define X2APIC_LVT_LINT0_MSR     (0x835)
#define X2APIC_LVT_LINT1_MSR     (0x836)
#define X2APIC_LVT_ERROR_MSR     (0x837)
#define X2APIC_INITIAL_COUNT_MSR (0x838)
#define X2APIC_CURRENT_COUNT_MSR (0x839)
#define X2APIC_DCR_MSR           (0x83E)
#define X2APIC_SELF_IPI_MSR      (0x83F)

#endif /* KERNEL_ASSEMBLY_H */
