#ifndef KERNEL_STDINT_H
#define KERNEL_STDINT_H

typedef __signed__ char  int8_t;
typedef __signed__ short int16_t;
typedef __signed__ int   int32_t;
typedef __signed__ long  int64_t;
typedef __signed__ long  intmax_t;

typedef unsigned char  uint8_t;
typedef unsigned short uint16_t;
typedef unsigned int   uint32_t;
typedef unsigned long  uint64_t;
typedef unsigned long  uintmax_t;

typedef unsigned long size_t;

#endif /* KERNEL_STDINT_H */
