global make_page_tables:function

section .text
bits 32
	
make_page_tables:
	;; PML4
	mov edi, PML4Tables
	mov eax, PDPTIdentity
	mov al, 11b
	mov [edi], eax

	mov edi, PML4Tables
	add edi, 0xC00
	mov eax, PDPTKernel
	mov al, 11b
	mov [edi], eax

	;; PDPTIdentity
	mov edi, PDPTIdentity
	mov eax, PDTIdentity
	mov al, 11b
	mov [edi], eax

	;; PDTIdentity
	mov edi, PDTIdentity
	xor eax, eax
	mov al, 10000011b
	mov [edi], eax

	;; PDPTKernel
	mov edi, PDPTKernel
	mov eax, PDTKernel
	mov al, 11b
	mov [edi], eax

	;; PDTKernel
	mov edi, PDTKernel
	xor eax, eax
	mov al, 10000011b
	mov [edi], eax

	add eax, 0x200000
	mov [edi+8], eax

	ret

global PML4Tables, PDPTIdentity, PDPTKernel
align 4096
PML4Tables:
	times 4096 db 0
PDPTIdentity:
	times 4096 db 0
PDTIdentity:
	times 4096 db 0
PDPTKernel:
	times 4096 db 0
PDTKernel:
	times 4096 db 0
PTKernel:
	times (4096 * 1) db 0
PTEnd:
