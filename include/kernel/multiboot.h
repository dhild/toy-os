#ifndef KERNEL_MULTIBOOT_H
#define KERNEL_MULTIBOOT_H

#include <kernel/stdint.h>

#define MULTIBOOT_TAG_ALIGN                 8
#define MULTIBOOT_TAG_TYPE_END              0
#define MULTIBOOT_TAG_TYPE_CMDLINE          1
#define MULTIBOOT_TAG_TYPE_BOOT_LOADER_NAME 2
#define MULTIBOOT_TAG_TYPE_MODULE           3
#define MULTIBOOT_TAG_TYPE_BASIC_MEMINFO    4
#define MULTIBOOT_TAG_TYPE_BOOTDEV          5
#define MULTIBOOT_TAG_TYPE_MMAP             6
#define MULTIBOOT_TAG_TYPE_VBE              7
#define MULTIBOOT_TAG_TYPE_FRAMEBUFFER      8
#define MULTIBOOT_TAG_TYPE_ELF_SECTIONS     9
#define MULTIBOOT_TAG_TYPE_APM             10

typedef struct __attribute__((__packed__)) multiboot_color {
  uint8_t red;
  uint8_t green;
  uint8_t blue;
} multiboot_color;

typedef struct __attribute__((__packed__)) multiboot_mmap_entry {
  uint64_t addr;
  uint64_t len;
  #define MULTIBOOT_MEMORY_AVAILABLE        1
  #define MULTIBOOT_MEMORY_RESERVED         2
  #define MULTIBOOT_MEMORY_ACPI_RECLAIMABLE 3
  #define MULTIBOOT_MEMORY_NVS              4
  uint32_t type;
  uint32_t zero;
} multiboot_mmap_entry;

typedef struct __attribute__((__packed__)) multiboot_tag {
  uint32_t type;
  uint32_t size;
} multiboot_tag;

typedef struct __attribute__((__packed__)) multiboot_tag_string {
  uint32_t type;
  uint32_t size;
  char string;
} multiboot_tag_string;

typedef struct __attribute__((__packed__)) multiboot_tag_module {
  uint32_t type;
  uint32_t size;
  uint32_t mod_start;
  uint32_t mod_end;
  char cmdline;
} multiboot_tag_module;

typedef struct __attribute__((__packed__)) multiboot_tag_basic_meminfo {
  uint32_t type;
  uint32_t size;
  uint32_t mem_lower;
  uint32_t mem_upper;
} multiboot_tag_basic_meminfo;

typedef struct __attribute__((__packed__)) multiboot_tag_bootdev {
  uint32_t type;
  uint32_t size;
  uint32_t biosdev;
  uint32_t slice;
  uint32_t part;
} multiboot_tag_bootdev;

typedef struct __attribute__((__packed__)) multiboot_tag_mmap {
  uint32_t type;
  uint32_t size;
  uint32_t entry_size;
  uint32_t entry_version;
  multiboot_mmap_entry entries;
} multiboot_tag_mmap;

typedef struct __attribute__((__packed__)) multiboot_vbe_info_block {
  uint8_t external_specification[512];
} multiboot_vbe_info_block;

typedef struct __attribute__((__packed__)) multiboot_vbe_mode_info_block {
  uint8_t external_specification[512];
} multiboot_vbe_mode_info_block;

typedef struct __attribute__((__packed__)) multiboot_tag_vbe {
  uint32_t type;
  uint32_t size;
  uint16_t vbe_mode;
  uint16_t vbe_interface_seg;
  uint16_t vbe_interface_off;
  uint16_t vbe_interface_len;

  multiboot_vbe_info_block vbe_control_info;
  multiboot_vbe_mode_info_block vbe_mode_info;
} multiboot_tag_vbe;

typedef struct __attribute__((__packed__)) multiboot_tag_framebuffer_common {
  uint32_t type;
  uint32_t size;
  uint64_t framebuffer_addr;
  uint32_t framebuffer_pitch;
  uint32_t framebuffer_width;
  uint32_t framebuffer_height;
  uint8_t framebuffer_bpp;
  #define MULTIBOOT_FRAMEBUFFER_TYPE_INDEXED  0
  #define MULTIBOOT_FRAMEBUFFER_TYPE_RGB      1
  #define MULTIBOOT_FRAMEBUFFER_TYPE_EGA_TEXT 2
  uint8_t framebuffer_type;
  uint16_t reserved;
} multiboot_tag_framebuffer_common;

typedef struct __attribute__((__packed__)) multiboot_tag_framebuffer {
  multiboot_tag_framebuffer_common common;

  union data_union {
    struct __attribute__((__packed__)) palette {
      uint16_t framebuffer_palette_num_colors;
      multiboot_color framebuffer_palette;
    };
    struct __attribute__((__packed__)) field_mask {
      uint8_t framebuffer_red_field_position;
      uint8_t framebuffer_red_mask_size;
      uint8_t framebuffer_green_field_position;
      uint8_t framebuffer_green_mask_size;
      uint8_t framebuffer_blue_field_position;
      uint8_t framebuffer_blue_mask_size;
    };
  };
} multiboot_tag_framebuffer;

typedef struct __attribute__((__packed__)) multiboot_tag_elf_sections {
  uint32_t type;
  uint32_t size;
  uint32_t num;
  uint32_t entsize;
  uint32_t shndx;
  char sections;
} multiboot_tag_elf_sections;

typedef struct __attribute__((__packed__)) multiboot_tag_apm {
  uint32_t type;
  uint32_t size;
  uint16_t version;
  uint16_t cseg;
  uint32_t offset;
  uint16_t cseg_16;
  uint16_t dseg;
  uint16_t flags;
  uint16_t cseg_len;
  uint16_t cseg_16_len;
  uint16_t dseg_len;
} multiboot_tag_apm;


#endif /* KERNEL_MULTIBOOT_H */
