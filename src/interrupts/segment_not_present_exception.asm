global segment_not_present_exception
extern print_string
bits 64
section .text

segment_not_present_exception:
	mov rdi, message
	call print_string
	iretq

section .data

message:
	db 'Segment not present exception!'
	db 0xA, 0
