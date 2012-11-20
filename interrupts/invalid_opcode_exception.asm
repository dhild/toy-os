global invalid_opcode_exception
extern print_string
bits 64
section .text

invalid_opcode_exception:
	mov rdi, message
	call print_string
	iretq

section .data

message:
	db 'Invalid Opcode Exception!'
	db 0xA, 0
