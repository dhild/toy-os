global nmi_interrupt
extern print_string
bits 64
section .text

nmi_interrupt:
	mov rdi, message
	call print_string
	iretq

section .data:

message:
	db 'Non-Maskable Interrupt!'
	db 0xA, 0
