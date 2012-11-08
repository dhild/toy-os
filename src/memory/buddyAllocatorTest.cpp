#include "buddyAllocator.h"
#include "testFunctions.h"
#include "types.h"
#include "kprintf.h"

using namespace buddy;

#define TEST_MEM_SIZE (3 * BUDDY_MAX_PAGE_SIZE)
byte mem[TEST_MEM_SIZE];

void testBuddyAllocator() {
  BuddyAllocator ba(mem, TEST_MEM_SIZE);

  void* p1 = ba.allocate(BUDDY_PAGE_SIZE(0));

  print_string("P1 address: ");
  print_hex((qword)p1);
  print_string("\n");

  void* p2 = ba.allocate(BUDDY_PAGE_SIZE(1));

  print_string("P2 address: ");
  print_hex((qword)p2);
  print_string("\n");

  void* p3 = ba.allocate(BUDDY_PAGE_SIZE(0) / 2);

  print_string("P3 address: ");
  print_hex((qword)p3);
  print_string("\n");

  void* p4 = ba.allocate(BUDDY_PAGE_SIZE(0) + 3);

  print_string("P4 address: ");
  print_hex((qword)p4);
  print_string("\n");

  ba.free(p2);
  p2 = (void*)NULL;

  ba.free(p4);
  p4 = (void*)NULL;

  ba.free(p1);
  p1 = (void*)NULL;

  ba.free(p3);
  p3 = (void*)NULL;

  print_string("Deletions complete.\n");
}
