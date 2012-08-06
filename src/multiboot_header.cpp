#define MULTIBOOT_MAGIC 0x1BADB002

#define ALIGN_MODULES 0x00000001
#define MEM_MAP       0x00000002
#define VIDEO         0x00000004
#define FORMAT_AOUT   0x00010000

#define MULTIBOOT_FLAGS (ALIGN_MODULES | MEM_MAP | VIDEO)

#define MULTIBOOT_CHECKSUM (0 - MULTIBOOT_MAGIC - MULTIBOOT_FLAGS)

struct MagicHeader {
  unsigned int magic;
  unsigned int flags;
  unsigned int checksum;
  unsigned int header_addr;
  unsigned int load_addr;
  unsigned int load_end_addr;
  unsigned int bss_end_addr;
  unsigned int entry_addr;
  unsigned int mode_type; // '0' for linear, '1' for EGA-standard text
  unsigned int width; // number of columns, '0' for no preference
  unsigned int height; // number of lines, '0' for no preference
  unsigned int depth; // number of bits per pixel, '0' for no preference
} header = { 
  MULTIBOOT_MAGIC,
  MULTIBOOT_FLAGS,
  MULTIBOOT_CHECKSUM,
  0, // contained in ELF
  0, // contained in ELF
  0, // contained in ELF
  0, // contained in ELF
  0, // contained in ELF
  0x1, // EGA-standard text
  0, // width, no preference
  0, // height, no preference
  0 // depth, no preference
};
