#include "interrupts.h"
#include "kprintf.h"

#define breakpoint asm ( "xchg %bx,%bx" );

void divide_error_exception() {
    breakpoint
    print_string( "Divide error exception!\n" );
}

void debug_exception() {
    breakpoint
    print_string( "Debug exception!\n" );
}

void nmi_interrupt() {
    breakpoint
    print_string( "Non-maskable interrupt!\n" );
}

void breakpoint_exception() {
    breakpoint
    print_string( "Breakpoint exception!\n" );
}

void overflow_exception() {
    breakpoint
    print_string( "Overflow exception!\n" );
}

void bound_range_exceeded_exception() {
    breakpoint
    print_string( "Bound range exceeded exception!\n" );
}

void invalid_opcode_exception() {
    breakpoint
    print_string( "Invalid opcode exception!\n" );
}

void device_not_available_exception() {
    breakpoint
    print_string( "Device not available exception!\n" );
}

void double_fault_exception() {
    breakpoint
    print_string( "Double fault exception!\n" );
}

void invalid_tss_exception() {
    breakpoint
    print_string( "Invalid TSS exception!\n" );
}

void segment_not_present_exception() {
    breakpoint
    print_string( "Segment not present exception!\n" );
}

void stack_fault_exception() {
    breakpoint
    print_string( "Stack fault exception!\n" );
}

void general_protection_exception() {
    breakpoint
    print_string( "General protection exception!\n" );
}

void page_fault_exception() {
    breakpoint
    print_string( "Page fault exception!\n" );
}

void x87_fpu_floating_point_error() {
    breakpoint
    print_string( "x87 fpu floating point error!\n" );
}

void alignment_check_exception() {
    breakpoint
    print_string( "Alignment check exception!\n" );
}

void machine_check_exception() {
    breakpoint
    print_string( "Machine check exception!\n" );
}

void simd_floating_point_exception() {
    breakpoint
    print_string( "SIMD floating point exception!\n" );
}
