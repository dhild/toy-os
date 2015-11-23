global setup_interrupts:function
bits 64

extern KernelCodeSeg

;; Intel defined processor interrupts.
;; These are hard-coded and cannot be changed.
%define DE_VECTOR 0x00
%define NMI_VECTOR 0x02
%define BP_VECTOR 0x03
%define OF_VECTOR 0x04
%define BR_VECTOR 0x05
%define UD_VECTOR 0x06
%define NM_VECTOR 0x07
%define DF_VECTOR 0x08
%define COP_VECTOR 0x09
%define TS_VECTOR 0x0A
%define NP_VECTOR 0x0B
%define SS_VECTOR 0x0C
%define GP_VECTOR 0x0D
%define PF_VECTOR 0x0E
%define MF_VECTOR 0x10
%define AC_VECTOR 0x11
%define MC_VECTOR 0x12
%define XM_VECTOR 0x13

;; Intel manual states that vectors 32-255 are user-defined.

;; Following the linux lead, we'll set the IRQ vectors to be vectors 32-48.
%define IRQ0_VECTOR 0x20
%define IRQ1_VECTOR (IRQ0_VECTOR + 1)
%define IRQ2_VECTOR (IRQ0_VECTOR + 2)
%define IRQ3_VECTOR (IRQ0_VECTOR + 3)
%define IRQ4_VECTOR (IRQ0_VECTOR + 4)
%define IRQ5_VECTOR (IRQ0_VECTOR + 5)
%define IRQ6_VECTOR (IRQ0_VECTOR + 6)
%define IRQ7_VECTOR (IRQ0_VECTOR + 7)
%define IRQ8_VECTOR (IRQ0_VECTOR + 8)
%define IRQ9_VECTOR (IRQ0_VECTOR + 9)
%define IRQ10_VECTOR (IRQ0_VECTOR + 10)
%define IRQ11_VECTOR (IRQ0_VECTOR + 11)
%define IRQ12_VECTOR (IRQ0_VECTOR + 12)
%define IRQ13_VECTOR (IRQ0_VECTOR + 13)
%define IRQ14_VECTOR (IRQ0_VECTOR + 14)
%define IRQ15_VECTOR (IRQ0_VECTOR + 15)

;; Now for some APIC vectors. These are organized by priority.
%define APIC_TIMER_VECTOR    0xef
%define APIC_LINT0_VECTOR    0xf0
%define APIC_LINT1_VECTOR    0xf1
%define APIC_PERF_MON_VECTOR 0xf2
%define APIC_THERMAL_VECTOR  0xfa
%define APIC_ERROR_VECTOR    0xfe
%define APIC_SPURIOUS_VECTOR 0xff

section .data

align 8
table:
%rep 256
	dd 0			; Reserved
	dd 0			; Offset
	dd 0			; Offset + flags
	dd 0			; Segment + offset
%endrep
.Pointer:			; The IDTpointer.
	dw (256 * 16)		; Limit.
	dq table		; Base.

	;; Arguments: vector_num, entry_address, IST, flags (15:0) of dword 1
%macro IDTentry 4
	extern %2
	;; Sets an interrupt descriptor
	;; dword 0: (31:16) segment selector
	;;          (15:00) offset 15:00
	;; dword 1: (31:16) offset 31:16
	;;          (15:08) P | DPL | 0 | Type
	;;          (08:00) 00000 | IST
	;; dword 2: (31:00) offset 63:32
	;; dword 3: (31:00) Reserved
	
	;; Set rdi to point to the descriptor:
	mov rdi, %1
	shl rdi, 4
	mov rax, table
	add rdi, rax

	;; Fill in the offset bytes:
	mov rax, %2
	mov word [rdi], ax
	shr rax, 16
	mov word [rdi+6], ax
	shr rax, 16
	mov dword [rdi+8], eax

	;; Fill in the segment selector
	mov ax, KernelCodeSeg
	mov word [rdi+2], ax

	;; Fill out the flags:
	mov ax, %3
	and ax, 0x7
	or ax, %4
	mov word [rdi+4], ax
%endmacro

%define INT_GATE 0x8E00
%define TRAP_GATE 0x8F00

section .text

	;; Sets up the interrupt tables with the basic interrupts defined as in	
	;; kernel/interrupts.h.
setup_interrupts:
	;; Install the base interrupt handlers

	IDTentry DE_VECTOR, divide_error_trap_gate, 0, TRAP_GATE
	IDTentry NMI_VECTOR, nmi_interrupt_gate, 1, INT_GATE
	IDTentry SS_VECTOR, stack_seg_fault_interrupt_gate, 6, INT_GATE
	IDTentry GP_VECTOR, general_protection_trap_gate, 0, TRAP_GATE
	IDTentry PF_VECTOR, page_fault_trap_gate, 0, TRAP_GATE
	IDTentry MC_VECTOR, machine_check_interrupt_gate, 3, INT_GATE

	IDTentry IRQ0_VECTOR, irq0_trap_gate, 0, TRAP_GATE
	IDTentry IRQ1_VECTOR, irq1_trap_gate, 0, TRAP_GATE
	IDTentry IRQ2_VECTOR, irq2_trap_gate, 0, TRAP_GATE
	IDTentry IRQ3_VECTOR, irq3_trap_gate, 0, TRAP_GATE
	IDTentry IRQ4_VECTOR, irq4_trap_gate, 0, TRAP_GATE
	IDTentry IRQ5_VECTOR, irq5_trap_gate, 0, TRAP_GATE
	IDTentry IRQ6_VECTOR, irq6_trap_gate, 0, TRAP_GATE
	IDTentry IRQ7_VECTOR, irq7_trap_gate, 0, TRAP_GATE
	IDTentry IRQ8_VECTOR, irq8_trap_gate, 0, TRAP_GATE
	IDTentry IRQ9_VECTOR, irq9_trap_gate, 0, TRAP_GATE
	IDTentry IRQ10_VECTOR, irq10_trap_gate, 0, TRAP_GATE
	IDTentry IRQ11_VECTOR, irq11_trap_gate, 0, TRAP_GATE
	IDTentry IRQ12_VECTOR, irq12_trap_gate, 0, TRAP_GATE
	IDTentry IRQ13_VECTOR, irq13_trap_gate, 0, TRAP_GATE
	IDTentry IRQ14_VECTOR, irq14_trap_gate, 0, TRAP_GATE
	IDTentry IRQ15_VECTOR, irq15_trap_gate, 0, TRAP_GATE

	IDTentry APIC_TIMER_VECTOR, apic_timer_trap_gate, 0, TRAP_GATE
	IDTentry APIC_LINT0_VECTOR, apic_lint0_trap_gate, 0, TRAP_GATE
	IDTentry APIC_LINT1_VECTOR, apic_lint1_trap_gate, 0, TRAP_GATE
	IDTentry APIC_PERF_MON_VECTOR, apic_perf_mon_interrupt_gate, 5, INT_GATE
	IDTentry APIC_THERMAL_VECTOR, apic_thermal_interrupt_gate, 5, INT_GATE
	IDTentry APIC_ERROR_VECTOR, apic_error_interrupt_gate, 5, INT_GATE
	IDTentry APIC_SPURIOUS_VECTOR, apic_spurious_interrupt_gate, 5, INT_GATE
	
	;; Load the interrupt table
	mov rax, table.Pointer
	lidt [rax]
	
	ret
