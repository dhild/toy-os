global alignment_check_exception
extern print_string
bits 64
section .text

alignment_check_exception:
	mov rdi, message
	call print_string
	iretq

section .data

message:
	db 'Alignment check exception!'
	db 0xA, 0
