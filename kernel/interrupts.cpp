#include <kernel/stdint.h>
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

  IDT_table IDT;

  static inline void lidt() {
    struct {
      uint16_t length;
      uint64_t address;
    } __attribute__((__packed__)) IDTR;

    IDTR.length = sizeof(IDT_table);
    /* We want the address to be in the 'identity' paging area.
     * We also know that this is within the first 1Gb of memory, physically.
     */
    IDTR.address = ((uint64_t)(&IDT)) & ((uint64_t)((1024 * 1024 * 1024) - 1));

    asm volatile ("lidt (%0)" : : "p"(&IDTR) : "memory");
  }
}

void interrupts::setup_interrupts() {
  /* Mark all entries as nonexistent until we set them. */
  memset(&IDT, 0, sizeof(IDT));

  /* Load the IDT register. */
  lidt();

  /* See if there is a local APIC */
  uint32_t eax, ebx, ecx, edx;
  cpuid(1, &eax, &ebx, &ecx, &edx);

  if (!(edx & (1<<9))) {
    log::panic("setup_interrupts()", "No local APIC!");
  }

  if (!(ecx & (1<<21))) {
    log::panic("setup_interrupts()", "No local x2APIC!");
  }

  /* Now enable the x2APIC mode */
  uint64_t apic_msr = readMSR(IA32_APIC_BASE_MSR);
  apic_msr |= (1 << 10) | (1 << 11);
  writeMSR(IA32_APIC_BASE_MSR, apic_msr);

  log::debug("setup_interrupts()", "x2APIC Enabled");

  

}
