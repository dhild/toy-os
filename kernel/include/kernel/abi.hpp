#ifndef TOY_OS_THREADING_HPP
#define TOY_OS_THREADING_HPP

#include <kernel/config.hpp>

namespace __cxxabiv1
{
#ifdef __GNUC__
    /* guard variables */

    /* The ABI requires a 64-bit type.  */
    __extension__ typedef int __guard __attribute__((mode(__DI__)));

    extern "C" int __cxa_guard_acquire (__guard *);
    extern "C" void __cxa_guard_release (__guard *);
    extern "C" void __cxa_guard_abort (__guard *);
#endif /* __GNUC__ */
}

#endif //TOY_OS_THREADING_HPP
