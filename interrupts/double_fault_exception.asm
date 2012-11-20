global double_fault_exception
extern print_string
bits 64
section .text

double_fault_exception:
	xchg bx, bx
	mov rdi, message
	call print_string
	iretq

section .data

message:
	db 'Double fault exception!'
	db 0xA, 0
