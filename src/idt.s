global setup_interrupts:function
global set_interrupt:function
global set_trap:function

extern CodeSeg, DataSeg

%define breakpoint  xchg bx,bx

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
	breakpoint
	cli

	;; Zero out the tables
	mov rdi, table
	xor rax, rax
	mov rcx, 512
	rep stosd

	;; Install the base interrupt handlers

	mov rdi, 0x00
	mov rsi, interrupt_0
	call set_interrupt

	mov rdi, 0x01
	mov rsi, interrupt_1
	call set_interrupt

	mov rdi, 0x02
	mov rsi, interrupt_2
	call set_interrupt

	mov rdi, 0x03
	mov rsi, interrupt_3
	call set_interrupt

	mov rdi, 0x04
	mov rsi, interrupt_4
	call set_interrupt

	mov rdi, 0x05
	mov rsi, interrupt_5
	call set_interrupt

	mov rdi, 0x06
	mov rsi, interrupt_6
	call set_interrupt

	mov rdi, 0x07
	mov rsi, interrupt_7
	call set_interrupt

	mov rdi, 0x08
	mov rsi, interrupt_8
	call set_interrupt

	mov rdi, 0x0A
	mov rsi, interrupt_10
	call set_interrupt

	mov rdi, 0x0B
	mov rsi, interrupt_11
	call set_interrupt

	mov rdi, 0x0C
	mov rsi, interrupt_12
	call set_interrupt

	mov rdi, 0x0D
	mov rsi, interrupt_13
	call set_interrupt

	mov rdi, 0x0E
	mov rsi, interrupt_14
	call set_interrupt

	mov rdi, 0xA0
	mov rsi, interrupt_16
	call set_interrupt

	mov rdi, 0xA1
	mov rsi, interrupt_17
	call set_interrupt

	mov rdi, 0xA2
	mov rsi, interrupt_18
	call set_interrupt

	mov rdi, 0xA3
	mov rsi, interrupt_19
	call set_interrupt

	breakpoint

	;; Enable the interrupts and return
	lidt [table.Pointer]
	sti
	ret

; void set_interrupt( byte number in rdi, void (*handler)() in rsi )
set_interrupt:

    mov rcx, 0xE ; Type: 64-bit interrupt gate

    jmp load_descriptor ; This will return to the caller when done

; void set_trap( byte number in rdi, void (*handler)() in rsi );
set_trap:
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

	ret

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

interrupt_0:
	breakpoint
	call divide_error_exception
	iretq

interrupt_1:
	breakpoint
	call debug_exception
	iretq

interrupt_2:
	breakpoint
	call nmi_interrupt
	iretq

interrupt_3:
	breakpoint
	call breakpoint_exception
	iretq

interrupt_4:
	breakpoint
	call overflow_exception
	iretq

interrupt_5:
	breakpoint
	call bound_range_exceeded_exception
	iretq

interrupt_6:
	breakpoint
	call invalid_opcode_exception
	iretq

interrupt_7:
	breakpoint
	call device_not_available_exception
	iretq

interrupt_8:
	breakpoint
	call double_fault_exception
	iretq

interrupt_10:
	breakpoint
	call invalid_tss_exception
	iretq

interrupt_11:
	breakpoint
	call segment_not_present_exception
	iretq

interrupt_12:
	breakpoint
	call stack_fault_exception
	iretq

interrupt_13:
	breakpoint
	call general_protection_exception
	iretq

interrupt_14:
	breakpoint
	call page_fault_exception
	iretq

interrupt_16:
	breakpoint
	call x87_fpu_floating_point_error
	iretq

interrupt_17:
	breakpoint
	call alignment_check_exception
	iretq

interrupt_18:
	breakpoint
	call machine_check_exception
	iretq

interrupt_19:
	breakpoint
	call simd_floating_point_exception
	iretq
