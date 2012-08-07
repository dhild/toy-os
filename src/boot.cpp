/* 
 * File:   boot.cpp
 * Author: D. Ryan Hild
 *
 * Created on May 24, 2010, 6:33 PM
 */

#include "main.h"
#include "multiboot.h"
#include "idt.h"
#include "types.h"
#include "kprintf.h"
#include "kdebug.h"

/** Main entry function, called as soon as 64-bit mode is enabled.
 */
void boot( struct mb_header *header ) {
    
  // Enable debugging with gdb:
  //set_debug_traps();
  //breakpoint();
  // Before these can be enabled, need to find a 64-bit debugger....

  dword flags = header->flags;

  // Enable kernel printing....
  if ( flags & MB_FLAGS_GRAPHICS_TABLE ) {
    setup_printing( header->vbe_control_info,
		    header->vbe_mode_info,
		    header->vbe_mode,
		    header->vbe_interface_seg,
		    header->vbe_interface_off,
		    header->vbe_interface_len );
  } else {
    setup_printing( 0, 0, 0, 0, 0, 0 );
  }

  // This needs to be done as soon as possible after booting.
  // The interrupts themselves will call printing methods, however,
  // so this will need to wait until after setup_printing()....
  setup_interrupts();

  kbreak();
  print_string( "Printing enabled!\n" );
  kbreak();
  print_hex( 0xDEADBEEF );
  kbreak();
  print_string( "\n" );
  kbreak();
  print_dec( 1234567890 );
  kbreak();
  print_string( "\n" );
  kbreak();

  if ( flags & MB_FLAGS_MEM_INFO ) {
//        unsigned int mem_lower;     // flags[0]
//        unsigned int mem_upper;     // flags[0]
  }
  if ( flags & MB_FLAGS_BOOT_DEVICE_INFO ) {
//        device boot_device;         // flags[1]
  }
  if ( flags & MB_FLAGS_COMMAND_LINE ) {
//        char* cmdline;              // flags[2]
  }
  if ( flags & MB_FLAGS_MODULES_INFO ) {
//        unsigned int mods_count;    // flags[3]
//        void* mods_addr;            // flags[3]
  }
  if ( flags & MB_FLAGS_ELF_INFO ) {
//        elf_info info;              // flags[5] (flags[4] is for a.out)
  }
  if ( flags & MB_FLAGS_MEM_MAP ) {
//        unsigned int mmap_length;   // flags[6]
//        void* mmap_addr;            // flags[6]
  }
  if ( flags & MB_FLAGS_DRIVES_INFO ) {
//        unsigned int drives_length; // flags[7]
//        void* drives_addr;          // flags[7]
  }
  if ( flags & MB_FLAGS_ROM_CONFIG_TABLE ) {
//        void* config_table;         // flags[8]
  }
  if ( flags & MB_FLAGS_BOOT_LOADER_NAME ) {
//        char* boot_loader_name;     // flags[9]
  }
  if ( flags & MB_FLAGS_APM_TABLE ) {
//        void* apm_table;            // flags[10]
  }
  if ( flags & MB_FLAGS_GRAPHICS_TABLE ) {
//        void* vbe_control_info;     // flags[11]
//        void* vbe_mode_info;        // flags[11]
//        void* vbe_mode;             // flags[11]
//        void* vbe_interface_seg;    // flags[11]
//        void* vbe_interface_off;    // flags[11]
//        void* vbe_interface_len;    // flags[11]
  }

  kmain();
}

