#ifndef VIDEO_H
#define VIDEO_H

#ifdef __cplusplus
extern "C" {
#endif

void putchar(int c);
void puts(const char* s);

void clearScreen();
void scrollScreen();

#ifdef __cplusplus
}
#endif

#endif /* VIDEO_H */
