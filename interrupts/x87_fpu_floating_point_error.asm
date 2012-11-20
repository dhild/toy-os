global x87_fpu_floating_point_error
extern print_string
bits 64
section .text

x87_fpu_floating_point_error:
	mov rdi, message
	call print_string
	iretq

section .data

message:
	db 'x87 FPU floating point error!'
	db 0xA, 0
