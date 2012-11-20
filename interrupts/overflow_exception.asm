global overflow_exception
extern print_string
bits 64
section .text

overflow_exception:
	mov rdi, message
	call print_string
	iretq

section .data

message:
	db 'Overflow exception!'
	db 0xA, 0
