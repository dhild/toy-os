global breakpoint_exception
extern print_string
extern store_print_regs
bits 64
section .text

breakpoint_exception:
	call store_print_regs

	mov rdi, message
	call print_string

	iretq

section .data

message:
	db 'Breakpoint detected!'
	db 0xA, 0
