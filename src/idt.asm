global setup_interrupts:function

extern CodeSeg

extern divide_error_exception
extern debug_exception
extern nmi_interrupt
extern breakpoint_exception
extern overflow_exception
extern bound_range_exceeded_exception
extern invalid_opcode_exception
extern device_not_available_exception
extern double_fault_exception
extern invalid_tss_exception
extern segment_not_present_exception
extern stack_fault_exception
extern general_protection_exception
extern page_fault_exception
extern x87_fpu_floating_point_error
extern alignment_check_exception
extern machine_check_exception
extern simd_floating_point_exception

bits 64

section .data

align 8
table:
	times (256 * 16) db 0
.Pointer:			; The IDT-pointer.
	dw (256 * 16)		; Limit.
	dq table		; Base.

section .text

	;; Sets up the interrupt tables with the basic interrupts defined as in
	;; interrupts.h. All other interrupts are blank.
	;; void setup_interrupts();
setup_interrupts:

	;; Install the base interrupt handlers
%macro interrupt 2
	;; Sets an interrupt descriptor
	;; dword 0: (31:16) segment selector
	;;          (15:00) offset 15:00
	;; dword 1: (31:16) offset 31:16
	;;          (15:08) P | DPL | 0 | Type
	;;          (08:00) 00000 | IST
	;; dword 2: (31:00) offset 63:32
	;; dword 3: (31:00) Reserved (sign extended of offset)

	;; Set rdi to point to the descriptor:
	mov rdi, %1
	shl rdi, 4
	add rdi, table

	;; dword 0
	mov rbx, %2
	mov word [rdi], bx
	mov word [rdi+2], CodeSeg

	;; dword 1
	mov eax, ebx
	and eax, 0xFFFF0000
	or ax, 0x8E00
	mov dword [rdi+4], eax

	;; dword 2 and 3
	sar rbx, 32
	mov qword [rdi+8], rbx
%endmacro

	interrupt 0, divide_error_exception
	interrupt 1, debug_exception
	interrupt 2, nmi_interrupt
	interrupt 3, breakpoint_exception
	interrupt 4, overflow_exception
	interrupt 5, bound_range_exceeded_exception
	interrupt 6, invalid_opcode_exception
	interrupt 7, device_not_available_exception
	interrupt 8, double_fault_exception
	interrupt 10, invalid_tss_exception
	interrupt 11, segment_not_present_exception
	interrupt 12, stack_fault_exception
	interrupt 13, general_protection_exception
	interrupt 14, page_fault_exception
	interrupt 16, x87_fpu_floating_point_error
	interrupt 17, alignment_check_exception
	interrupt 18, machine_check_exception
	interrupt 19, simd_floating_point_exception

	xchg bx, bx
	;; Enable the interrupts and return
	lidt [table.Pointer]

	sti
	jmp r12
