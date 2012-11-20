global machine_check_exception
extern print_string
bits 64
section .text

machine_check_exception:
	mov rdi, message
	call print_string
	iretq

section .data

message:
	db 'Machine check exception!'
	db 0xA, 0
