;; Entries into interrupt vectors are much better
;; when using pure assembly code. This is where
;; they are entered into.

section .text
bits 64

%macro savestackmods 0
	push r11
	push r10
	push r9
	push r8
	push rax
	push rcx
	push rdx
	push rsi
	push rdi
%endmacro

%macro restorestackmods 0
	pop rdi
	pop rsi
	pop rdx
	pop rcx
	pop rax
	pop r8
	pop r9
	pop r10
	pop r11
%endmacro

%macro savestackall 0
	push r15
	push r14
	push r13
	push r12
	push rbp
	push rbx

	savestackmods
%endmacro

%macro restorestackall 0
	restorestackmods
	
	pop rbx
	pop rbp
	pop r12
	pop r13
	pop r14
	pop r15
%endmacro

global divide_error_trap_gate
divide_error_trap_gate:
	iretq

global nmi_interrupt_gate
nmi_interrupt_gate:
	iretq

global stack_seg_fault_interrupt_gate
stack_seg_fault_interrupt_gate:
	iretq

global general_protection_trap_gate
general_protection_trap_gate:
	iretq

global page_fault_trap_gate
page_fault_trap_gate:
	iretq

global machine_check_interrupt_gate
machine_check_interrupt_gate:
	iretq

global irq0_trap_gate
irq0_trap_gate:
	iretq

global irq1_trap_gate
irq1_trap_gate:
	iretq

global irq2_trap_gate
irq2_trap_gate:
	iretq

global irq3_trap_gate
irq3_trap_gate:
	iretq

global irq4_trap_gate
irq4_trap_gate:
	iretq

global irq5_trap_gate
irq5_trap_gate:
	iretq

global irq6_trap_gate
irq6_trap_gate:
	iretq

global irq7_trap_gate
irq7_trap_gate:
	iretq

global irq8_trap_gate
irq8_trap_gate:
	iretq

global irq9_trap_gate
irq9_trap_gate:
	iretq

global irq10_trap_gate
irq10_trap_gate:
	iretq

global irq11_trap_gate
irq11_trap_gate:
	iretq

global irq12_trap_gate
irq12_trap_gate:
	iretq

global irq13_trap_gate
irq13_trap_gate:
	iretq

global irq14_trap_gate
irq14_trap_gate:
	iretq

global irq15_trap_gate
irq15_trap_gate:
	iretq

global apic_timer_trap_gate
apic_timer_trap_gate:
	iretq

global apic_lint0_trap_gate
apic_lint0_trap_gate:
	iretq

global apic_lint1_trap_gate
apic_lint1_trap_gate:
	iretq

global apic_perf_mon_interrupt_gate
apic_perf_mon_interrupt_gate:
	iretq

global apic_thermal_interrupt_gate
apic_thermal_interrupt_gate:
	iretq

global apic_error_interrupt_gate
apic_error_interrupt_gate:
	iretq

global apic_spurious_interrupt_gate
apic_spurious_interrupt_gate:
	iretq
