#include "main.h"
#include "kprintf.h"
#include "multiboot.h"
#include "testFunctions.h"

/** This is called after the initialization procedure is finished.
 *
 */
extern "C" void kmain( struct mb_header *header ) {

  // All other code goes here
  print_string( "Printing enabled!\n" );
  print_hex( 0xDEADBEEF );
  print_string( "\n" );
  print_dec( 1234567890 );
  print_string( "\n" );

  dword flags = header->flags;
  flags++;


  testBuddyAllocator();
}

extern "C" void __cxa_pure_virtual()
{
  // TODO: Print an error message.
}
