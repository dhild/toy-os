global invalid_tss_exception
extern print_string
bits 64
section .text

invalid_tss_exception:
	mov rdi, message
	call print_string
	iretq

section .data

message:
	db 'Invalid TSS exception!'
	db 0xA, 0
