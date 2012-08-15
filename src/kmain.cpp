#include "main.h"
#include "kprintf.h"
#include "multiboot.h"

extern long unsigned int start_ctors, end_ctors, start_dtors, end_dtors;

/** This is called after the initialization procedure is finished.
 *
 */
extern "C" void kmain( struct mb_header *header ) {
  //- call all the static constructors in the list.
  for(unsigned long *constructor(&start_ctors); constructor < &end_ctors; ++constructor) {
    ((void (*) (void)) (*constructor)) ();
  }

  // All other code goes here
  print_string( "Printing enabled!\n" );
  print_hex( 0xDEADBEEF );
  print_string( "\n" );
  print_dec( 1234567890 );
  print_string( "\n" );

  dword flags = header->flags;
  flags++;

  //- call all the static destructors in the list.
  for(unsigned long *destructor(&start_dtors); destructor < &end_dtors; ++destructor) {
    ((void (*) (void)) (*destructor)) ();
  }
}

extern "C" void __cxa_pure_virtual()
{
  // TODO: Print an error message.
}
