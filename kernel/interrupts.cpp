#include <config.h>
#include <kernel/assembly.h>
#include <kernel/logging.h>
#include "interrupts.h"

typedef struct __attribute__((__packed__)) IDTEntry {
  __u16 segment;
  __u16 offset_0_15;
  __u16 offset_16_31;
  __u8  p_dpl_type_res;
  __u8  res_ist;
  __u32 offset_32_63;
  __u32 reserved;
} IDTEntry;

#define MASK_IST  ((__u8)0x07)
#define MASK_TYPE ((__u8)0x0F)
#define MASK_DPL  ((__u8)0x60)
#define MASK_P    ((__u8)0x80)

#define BITS_IST(x)   ((__u8)(MASK_IST & x))
#define BITS_P_DPL_TYPE(p,d,t) ((__u8)((MASK_P & (p << 7)) | \
				       (MASK_DPL & (d << 5)) | \
				       (MASK_TYPE & t)))
#define BITS_OFFSET_0(x) ((__u16)(0xFFFF & x))
#define BITS_OFFSET_1(x) ((__u16)(0xFFFF & (x >> 16)))
#define BITS_OFFSET_2(x) ((__u32)(0xFFFFFFFF & (x >> 32)))

namespace {
  typedef struct __attribute__((__packed__)) IDT_table {
    IDTEntry entry[256];
  } IDT_table;

  IDT_table IDT;
}

void interrupts::setup_interrupts() {
  /* Mark all entries as nonexistent until we set them. */
  for (int i = 0; i < 256; i++) {
    IDT.entry[0].p_dpl_type_res = 0;
  }

  /* See if there is a local APIC */
  __u32 eax, ebx, ecx, edx;
  cpuid(1, &eax, &ebx, &ecx, &edx);

  if (!(edx & (1<<9))) {
    log::panic("setup_interrupts()", "No local APIC!");
  }

  if (!(ecx & (1<<21))) {
    log::panic("setup_interrupts()", "No local x2APIC!");
  }

  /* Now enable the x2APIC mode */
  readMSR(IA32_APIC_BASE_MSR, &eax, &edx);
  eax |= (1 << 10) | (1 << 11);
  writeMSR(IA32_APIC_BASE_MSR, eax, edx);

  log::debug("setup_interrupts()", "x2APIC Enabled");
}
