global device_not_available_exception
extern print_string
bits 64
section .text

device_not_available_exception:
	mov rdi, message
	call print_string
	iretq

section .data

message:
	db 'Device not available exception!'
	db 0xA, 0
