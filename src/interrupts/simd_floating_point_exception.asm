global simd_floating_point_exception
extern print_string
bits 64
section .text

simd_floating_point_exception:
	mov rdi, message
	call print_string
	iretq

section .data

message:
	db 'SIMD floating point exception!'
	db 0xA, 0
