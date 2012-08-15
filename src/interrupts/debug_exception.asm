global debug_exception
extern print_string
bits 64
section .text

debug_exception:
	mov rdi, message
	call print_string
	iretq

section .data

message:
	db 'Debug exception!'
	db 0xA, 0
