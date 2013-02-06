#ifndef KERNEL_MULTIBOOT_H
#define KERNEL_MULTIBOOT_H

#include <config.h>

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
  __u8 red;
  __u8 green;
  __u8 blue;
} multiboot_color;

typedef struct __attribute__((__packed__)) multiboot_mmap_entry {
  __u64 addr;
  __u64 len;
  #define MULTIBOOT_MEMORY_AVAILABLE        1
  #define MULTIBOOT_MEMORY_RESERVED         2
  #define MULTIBOOT_MEMORY_ACPI_RECLAIMABLE 3
  #define MULTIBOOT_MEMORY_NVS              4
  __u32 type;
  __u32 zero;
} multiboot_mmap_entry;

typedef struct __attribute__((__packed__)) multiboot_tag {
  __u32 type;
  __u32 size;
} multiboot_tag;

typedef struct __attribute__((__packed__)) multiboot_tag_string {
  __u32 type;
  __u32 size;
  char string;
} multiboot_tag_string;

typedef struct __attribute__((__packed__)) multiboot_tag_module {
  __u32 type;
  __u32 size;
  __u32 mod_start;
  __u32 mod_end;
  char cmdline;
} multiboot_tag_module;

typedef struct __attribute__((__packed__)) multiboot_tag_basic_meminfo {
  __u32 type;
  __u32 size;
  __u32 mem_lower;
  __u32 mem_upper;
} multiboot_tag_basic_meminfo;

typedef struct __attribute__((__packed__)) multiboot_tag_bootdev {
  __u32 type;
  __u32 size;
  __u32 biosdev;
  __u32 slice;
  __u32 part;
} multiboot_tag_bootdev;

typedef struct __attribute__((__packed__)) multiboot_tag_mmap {
  __u32 type;
  __u32 size;
  __u32 entry_size;
  __u32 entry_version;
  multiboot_mmap_entry entries;
} multiboot_tag_mmap;

typedef struct __attribute__((__packed__)) multiboot_vbe_info_block {
  __u8 external_specification[512];
} multiboot_vbe_info_block;

typedef struct __attribute__((__packed__)) multiboot_vbe_mode_info_block {
  __u8 external_specification[512];
} multiboot_vbe_mode_info_block;

typedef struct __attribute__((__packed__)) multiboot_tag_vbe {
  __u32 type;
  __u32 size;
  __u16 vbe_mode;
  __u16 vbe_interface_seg;
  __u16 vbe_interface_off;
  __u16 vbe_interface_len;

  multiboot_vbe_info_block vbe_control_info;
  multiboot_vbe_mode_info_block vbe_mode_info;
} multiboot_tag_vbe;

typedef struct __attribute__((__packed__)) multiboot_tag_framebuffer_common {
  __u32 type;
  __u32 size;
  __u64 framebuffer_addr;
  __u32 framebuffer_pitch;
  __u32 framebuffer_width;
  __u32 framebuffer_height;
  __u8 framebuffer_bpp;
  #define MULTIBOOT_FRAMEBUFFER_TYPE_INDEXED  0
  #define MULTIBOOT_FRAMEBUFFER_TYPE_RGB      1
  #define MULTIBOOT_FRAMEBUFFER_TYPE_EGA_TEXT 2
  __u8 framebuffer_type;
  __u16 reserved;
} multiboot_tag_framebuffer_common;

typedef struct __attribute__((__packed__)) multiboot_tag_framebuffer {
  multiboot_tag_framebuffer_common common;

  union data_union {
    struct __attribute__((__packed__)) palette {
      __u16 framebuffer_palette_num_colors;
      multiboot_color framebuffer_palette;
    };
    struct __attribute__((__packed__)) field_mask {
      __u8 framebuffer_red_field_position;
      __u8 framebuffer_red_mask_size;
      __u8 framebuffer_green_field_position;
      __u8 framebuffer_green_mask_size;
      __u8 framebuffer_blue_field_position;
      __u8 framebuffer_blue_mask_size;
    };
  };
} multiboot_tag_framebuffer;

typedef struct __attribute__((__packed__)) multiboot_tag_elf_sections {
  __u32 type;
  __u32 size;
  __u32 num;
  __u32 entsize;
  __u32 shndx;
  char sections;
} multiboot_tag_elf_sections;

typedef struct __attribute__((__packed__)) multiboot_tag_apm {
  __u32 type;
  __u32 size;
  __u16 version;
  __u16 cseg;
  __u32 offset;
  __u16 cseg_16;
  __u16 dseg;
  __u16 flags;
  __u16 cseg_len;
  __u16 cseg_16_len;
  __u16 dseg_len;
} multiboot_tag_apm;


#endif /* KERNEL_MULTIBOOT_H */
