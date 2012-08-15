global breakpoint_exception
extern print_string
bits 64
section .text

breakpoint_exception:
	mov rdi, message
	call print_string
	iretq

section .data

message:
	db 'Breakpoint detected!', 0
