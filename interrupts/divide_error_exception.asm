global divide_error_exception:data
extern print_string
bits 64
section .text

divide_error_exception:
	mov rdi, message
	call print_string
	iretq

section .data

message:
	db 'Divide error exception!'
	db 0xA, 0
