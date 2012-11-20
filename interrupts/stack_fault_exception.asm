global stack_fault_exception
extern print_string
bits 64
section .text

stack_fault_exception:
	mov rdi, message
	call print_string
	iretq

section .data

message:
	db 'Stack fault exception!'
	db 0xA, 0
