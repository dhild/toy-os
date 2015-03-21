#include <stdint.h>
#include <kernel/string.h>
#include <kernel/assembly.h>
#include <kernel/logging.h>
#include "interrupts.h"

#define MASK_IST  ((uint8_t)0x07)
#define MASK_TYPE ((uint8_t)0x0F)
#define MASK_DPL  ((uint8_t)0x60)
#define MASK_P    ((uint8_t)0x80)

#define BITS_IST(x)   ((uint8_t)(MASK_IST & x))
#define BITS_P_DPL_TYPE(p,d,t) ((uint8_t)((MASK_P & (p << 7)) | \
                       (MASK_DPL & (d << 5)) | \
                       (MASK_TYPE & t)))
#define BITS_OFFSET_0(x) ((uint16_t)(0xFFFF & x))
#define BITS_OFFSET_1(x) ((uint16_t)(0xFFFF & (x >> 16)))
#define BITS_OFFSET_2(x) ((uint32_t)(0xFFFFFFFF & (x >> 32)))

namespace {

typedef struct __attribute__((__packed__)) IDTEntry {
    uint16_t segment;
    uint16_t offset_0_15;
    uint16_t offset_16_31;
    uint8_t  p_dpl_type_res;
    uint8_t  res_ist;
    uint32_t offset_32_63;
    uint32_t reserved;
} IDTEntry;

typedef struct __attribute__((__packed__)) IDT_table {
    IDTEntry entry[256];
} IDT_table;

IDT_table* IDT;

static inline void get_idt() {
    struct {
        uint16_t length;
        uint64_t address;
    } __attribute__((__packed__)) IDTR;

    asm volatile ("sidt (%0)" : : "p"(&IDTR) : "memory");

    IDT = (IDT_table*)IDTR.address;
}

uint64_t x2APIC_ID;
}

void interrupts::setup_interrupts() {
    /** Initialize our IDT pointer. */
    get_idt();

    /* See if there is a local APIC */
    uint32_t eax, ebx, ecx, edx;
    cpuid(1, &eax, &ebx, &ecx, &edx);

    if (!(edx & (1 << 9))) {
        log::panic("setup_interrupts()", "No local APIC!");
    }

    if (!(ecx & (1 << 21))) {
        log::panic("setup_interrupts()", "No local x2APIC!");
    }

    /* Now enable the x2APIC mode.
     * Start by disabling the PIC (or ensuring it is disabled).
     */
    asm volatile ("mov $0xff, %%al \n\t"
                  "out %%al, $0xa1 \n\t"
                  "out %%al, $0x21 \n\t"
                  ::: "al", "memory");
    /* Next, write the proper bits to the MSR to indicate we want the x2APIC. */
    uint64_t apic_msr = readMSR(IA32_APIC_BASE_MSR);
    apic_msr |= (1 << 10) | (1 << 11);
    writeMSR(IA32_APIC_BASE_MSR, apic_msr);

    log::debug("setup_interrupts()", "x2APIC Enabled");

    x2APIC_ID = readMSR(X2APIC_LOCAL_ID_MSR);

}

