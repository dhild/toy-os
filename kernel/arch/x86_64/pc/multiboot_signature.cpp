#include "kernel/multiboot2.h"

typedef unsigned char  uint8_t;
typedef unsigned short uint16_t;
typedef unsigned int   uint32_t;
typedef signed int     int32_t;

struct multiboot2_signature
{
  uint32_t magic;
  uint32_t architecture;
  uint32_t header_length;
  int32_t checksum;

  uint16_t mb_info_request_tag;
  uint16_t mb_info_flags;
  uint32_t size;
  uint32_t requests[4];

  uint16_t tag_end;
  uint16_t tag_end_flags;
  uint16_t tag_end_size;
} __attribute__((packed));

struct multiboot2_signature mb2_sig
__attribute__((section(".multiboot2_signature")))
__attribute__((aligned(MULTIBOOT_HEADER_ALIGN))) =
{
  MULTIBOOT2_HEADER_MAGIC,
  MULTIBOOT_ARCHITECTURE_I386,
  sizeof(multiboot2_signature),
  -(MULTIBOOT2_HEADER_MAGIC +
    MULTIBOOT_ARCHITECTURE_I386 +
    (int32_t) sizeof(multiboot2_signature)),

  MULTIBOOT_HEADER_TAG_INFORMATION_REQUEST,
  0,
  8 + (4 * 4),
  {
    MULTIBOOT_TAG_TYPE_ELF_SECTIONS,
    MULTIBOOT_TAG_TYPE_MMAP,
    MULTIBOOT_TAG_TYPE_BOOT_LOADER_NAME,
    MULTIBOOT_TAG_TYPE_FRAMEBUFFER
  },

  MULTIBOOT_TAG_TYPE_END,
  0,
  8
};
