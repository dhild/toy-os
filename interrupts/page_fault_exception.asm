global page_fault_exception
extern print_string
bits 64
section .text

page_fault_exception:
	mov rdi, message
	call print_string
	iretq

section .data

message:
	db 'Page fault exception!'
	db 0xA, 0
