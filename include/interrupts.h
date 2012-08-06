/* 
 * File:   interrupts.h
 * Author: D. Ryan Hild
 *
 * Created on May 30, 2010, 7:45 AM
 */

#ifndef _INTERRUPTS_H
#define	_INTERRUPTS_H

#include "types.h"

#ifdef	__cplusplus
extern "C" {
#endif

void set_interrupt( byte number, void (*handler)() );
void set_trap( byte number, void (*handler)() );

void divide_error_exception();
void debug_exception();
void nmi_interrupt();
void breakpoint_exception();
void overflow_exception();
void bound_range_exceeded_exception();
void invalid_opcode_exception();
void device_not_available_exception();
void double_fault_exception();
void invalid_tss_exception();
void segment_not_present_exception();
void stack_fault_exception();
void general_protection_exception();
void page_fault_exception();
void x87_fpu_floating_point_error();
void alignment_check_exception();
void machine_check_exception();
void simd_floating_point_exception();

#ifdef	__cplusplus
}
#endif

#endif	/* _INTERRUPTS_H */

