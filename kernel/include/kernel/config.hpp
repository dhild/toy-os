#ifndef KERNEL_CONFIG_HPP
#define KERNEL_CONFIG_HPP

#ifdef __GNUC__

#ifdef __INT8_TYPE__
typedef __INT8_TYPE__ int8_t;
#endif
#ifdef __INT16_TYPE__
typedef __INT16_TYPE__ int16_t;
#endif
#ifdef __INT32_TYPE__
typedef __INT32_TYPE__ int32_t;
#endif
#ifdef __INT64_TYPE__
typedef __INT64_TYPE__ int64_t;
#endif
#ifdef __UINT8_TYPE__
typedef __UINT8_TYPE__ uint8_t;
#endif
#ifdef __UINT16_TYPE__
typedef __UINT16_TYPE__ uint16_t;
#endif
#ifdef __UINT32_TYPE__
typedef __UINT32_TYPE__ uint32_t;
#endif
#ifdef __UINT64_TYPE__
typedef __UINT64_TYPE__ uint64_t;
#endif

#else

typedef unsigned char       uint8_t;
typedef unsigned short      uint16_t;
typedef unsigned int        uint32_t;
typedef unsigned long long  uint64_t;

typedef signed char       sint8_t;
typedef signed short      sint16_t;
typedef signed int        sint32_t;
typedef signed long long  sint64_t;

typedef char       int8_t;
typedef short      int16_t;
typedef int        int32_t;
typedef long long  int64_t;

#endif /* __GNUC__ */

#endif /* KERNEL_CONFIG_HPP */

