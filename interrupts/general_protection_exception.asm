global general_protection_exception
extern print_string
bits 64
section .text

general_protection_exception:
	mov rdi, message
	call print_string
	iretq

section .data

message:
	db 'General protection exception!'
	db 0xA, 0
