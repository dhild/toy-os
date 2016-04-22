#include "kernel/abi.hpp"

/*
 * For reference, see the one-time construction API, in the C++ ABI:
 * https://mentorembedded.github.io/cxx-abi/abi.html#once-ctor
 */

int __cxxabiv1::__cxa_guard_acquire(__cxxabiv1::__guard *g)
{
    //TODO: Not actually multithread safe!
    return *(char*)(g) != 0;
}

void __cxxabiv1::__cxa_guard_release(__cxxabiv1::__guard *g)
{
    //TODO: Not actually multithread safe!
    *(char *) g = 1;
}

void __cxxabiv1::__cxa_guard_abort(__guard *)
{
    //TODO: Not actually multithread safe!
}
