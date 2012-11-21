#include <boot/addresses.h>
#include <string.h>
#include <types.h>
#include <video.h>
#include "console.h"

__u64 width = 80;
__u64 height = 25;
__u8 charSize = 2;
__u64 cursorOffset = 0;

#define CURSOR_ADDRESS (__u16*)(BASE_ADDRESS + (cursorOffset * charSize))
#define TAB_SIZE (TAB_WIDTH * charSize)
#define LINE_SIZE (width * charSize)
#define VIDEO_SIZE (width * height * charSize)
#define VIDEO_ADDRESS(w,h) (void*)(BASE_ADDRESS + (h * LINE_SIZE) + (w * charSize))

void clearScreen() {
  memset((void*)BASE_ADDRESS, 0, VIDEO_SIZE);
  cursorOffset = 0;
}

void scrollScreen() {
  memcpy((void*)BASE_ADDRESS,
	 (void*)(BASE_ADDRESS + LINE_SIZE),
	 (height - 1) * LINE_SIZE);
  memset(VIDEO_ADDRESS(0, height - 1), 0, LINE_SIZE);

  if (cursorOffset > LINE_SIZE)
    cursorOffset -= LINE_SIZE;
}

void puts(const char *str) {
  while (*str)
    putchar(*str++);
}

void putchar(int c) {
  switch (c) {
  case '\n':
    cursorOffset += LINE_SIZE;
  case '\r':
    cursorOffset -= (cursorOffset % LINE_SIZE);
    break;
  case '\t':
    cursorOffset += TAB_SIZE - (cursorOffset % TAB_SIZE);
    break;
  default:
    *(CURSOR_ADDRESS) = (__u16)((c & 0xFF) | (ATTRIBUTE_BYTE << 8));
    cursorOffset += 2;
  }
  if ((__u64)CURSOR_ADDRESS > (__u64)VIDEO_ADDRESS(width, height))
    scrollScreen();
}
