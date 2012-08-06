#ifndef _MULTIBOOT_H_
#define _MULTIBOOT_H_

#include "types.h"

struct elf_info {
  dword num;
  dword size;
  dword addr;
  dword shndx;
};

#define MB_FLAGS_MEM_INFO         0x00000001
#define MB_FLAGS_BOOT_DEVICE_INFO 0x00000002
#define MB_FLAGS_COMMAND_LINE     0x00000004
#define MB_FLAGS_MODULES_INFO     0x00000008
#define MB_FLAGS_A_OUT_INFO       0x00000010
#define MB_FLAGS_ELF_INFO         0x00000020
#define MB_FLAGS_MEM_MAP          0x00000040
#define MB_FLAGS_DRIVES_INFO      0x00000080
#define MB_FLAGS_ROM_CONFIG_TABLE 0x00000100
#define MB_FLAGS_BOOT_LOADER_NAME 0x00000200
#define MB_FLAGS_APM_TABLE        0x00000400
#define MB_FLAGS_GRAPHICS_TABLE   0x00000800

struct mb_header {
  dword flags;

  dword mem_lower;     // flags[0]
  dword mem_upper;     // flags[0]

  dword boot_device; // flags[1]

  dword cmdline; // flags[2]

  dword mods_count;    // flags[3]
  dword mods_addr;     // flags[3]

  dword elf_info_num;   // flags[5] (flags[4] is for a.out)
  dword elf_info_size;  // flags[5] (flags[4] is for a.out)
  dword elf_info_addr;  // flags[5] (flags[4] is for a.out)
  dword elf_info_shndx; // flags[5] (flags[4] is for a.out)

  dword mmap_length;   // flags[6]
  dword mmap_addr;            // flags[6]

  dword drives_length; // flags[7]
  dword drives_addr;          // flags[7]

  dword config_table;         // flags[8]

  dword boot_loader_name;     // flags[9]

  dword apm_table;            // flags[10]

  dword vbe_control_info;     // flags[11]
  dword vbe_mode_info;        // flags[11]
  dword vbe_mode;             // flags[11]
  dword vbe_interface_seg;    // flags[11]
  dword vbe_interface_off;    // flags[11]
  dword vbe_interface_len;    // flags[11]
};

#endif // _MULTIBOOT_H_
