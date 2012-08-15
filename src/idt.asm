global setup_interrupts:function
global set_interrupt:function
global set_trap:function

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
	times (256 * 2) dq 0
.Pointer:			; The IDT-pointer.
	dw $ - table - 1	; Limit.
	dq table		; Base.

section .text

	;; Sets up the interrupt tables with the basic interrupts defined as in
	;; interrupts.h. All other interrupts are blank.
	;; void setup_interrupts();
setup_interrupts:
	push rdi
	push rsi
	push rax
	push rcx
	cli

	;; Zero out the tables
	mov rdi, table
	xor rax, rax
	mov rcx, 512
	rep stosd

	;; Install the base interrupt handlers

	mov rdi, 0x00
	mov rsi, divide_error_exception
	call set_interrupt

	mov rdi, 0x01
	mov rsi, debug_exception
	call set_interrupt

	mov rdi, 0x02
	mov rsi, nmi_interrupt
	call set_interrupt

	mov rdi, 0x03
	mov rsi, breakpoint_exception
	call set_interrupt

	mov rdi, 0x04
	mov rsi, overflow_exception
	call set_interrupt

	mov rdi, 0x05
	mov rsi, bound_range_exceeded_exception
	call set_interrupt

	mov rdi, 0x06
	mov rsi, invalid_opcode_exception
	call set_interrupt

	mov rdi, 0x07
	mov rsi, device_not_available_exception
	call set_interrupt

	mov rdi, 0x08
	mov rsi, double_fault_exception
	call set_interrupt

	;; 0x09 is  Coprocessor Segment Overrun
	;; Listed as Intel reserved, do not use.

	mov rdi, 0x0A
	mov rsi, invalid_tss_exception
	call set_interrupt

	mov rdi, 0x0B
	mov rsi, segment_not_present_exception
	call set_interrupt

	mov rdi, 0x0C
	mov rsi, stack_fault_exception
	call set_interrupt

	mov rdi, 0x0D
	mov rsi, general_protection_exception
	call set_interrupt

	mov rdi, 0x0E
	mov rsi, page_fault_exception
	call set_interrupt

	;; 0x0F is Intel reserved

	mov rdi, 0xA0
	mov rsi, x87_fpu_floating_point_error
	call set_interrupt

	mov rdi, 0xA1
	mov rsi, alignment_check_exception
	call set_interrupt

	mov rdi, 0xA2
	mov rsi, machine_check_exception
	call set_interrupt

	mov rdi, 0xA3
	mov rsi, simd_floating_point_exception
	call set_interrupt

	;; 0xA4 through 0xAF are Intel reserved.
	
	xchg bx, bx
	;; Enable the interrupts and return
	lidt [table.Pointer]

	pop rcx
	pop rax
	pop rsi
	pop rdi
	sti
	ret

; void set_interrupt( byte number in rdi, void (*handler)() in rsi )
set_interrupt:
	push rdi
	push rsi
	push rax
	push rcx
	
	mov rcx, 0xE	; Type: 64-bit interrupt gate

	jmp load_descriptor ; This will return to the caller when done

; void set_trap( byte number in rdi, void (*handler)() in rsi );
set_trap:
	push rdi
	push rsi
	push rax
	push rcx
	
	mov rcx, 0xF ; Type: 64-bit trap gate

; Loads an interrupt descriptor
; Params:
;       rdi - interrupt number
;       rsi - handler pointer
;       rcx - type flag
load_descriptor:
	;; dword 0: (31:16) segment selector
	;;          (15:00) offset 15:00
	;; dword 1: (31:16) offset 31:16
	;;          (15:08) P | DPL | 0 | Type
	;;          (08:00) 00000 | IST
	;; dword 2: (31:00) offset 63:32
	;; dword 3: (31:00) Reserved (sign extended of offset)

	;; Set rdi to point to the descriptor:
	and rdi, 0xFF
	shl rdi, 4
	add rdi, table

	;; rax first contains dwords 1 and 0:
	mov rax, rsi
	shr rax, 8
	and rax, 0xFFFF00
	or rax, 0x80
	or rax, rcx
	shl rax, 24
	mov cx, CodeSeg
	or ax, cx
	shl rax, 16
	or ax, si
	mov qword [rdi], rax

	;; Now dwords 3 and 2:
	mov rax, rsi
	sar rax, 32
	add rdi, 8
	mov qword [rdi], rax

	pop rcx
	pop rax
	pop rsi
	pop rdi
	ret
