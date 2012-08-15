global bound_range_exceeded_exception
extern print_string
bits 64
section .text

bound_range_exceeded_exception:
	mov rdi, message
	call print_string
	iretq

section .data

message:
	db 'BOUND Range Exceeded exception!'
	db 0xA, 0
