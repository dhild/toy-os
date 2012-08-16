global make_page_tables:function
global PML4Tables

section .text
align 4096
PML4Tables:
	dd 512
PDPTIdentity:
	dd 512
PDTIdentity:
	dd 512
PDPTKernel:
	dd 512
PDTKernel:
	dd 512
PTKernel:
	dd (251 * 512)
PTEnd:
	
section .text
bits 32
	
make_page_tables:
	;; Zero out all tables
	mov edi, PML4Tables
	mov ecx, PTEnd
	sub ecx, PML4Tables
	xor al, al
	rep stosb

	;; PML4
	mov edi, PML4Tables
	mov eax, PDPTIdentity
	mov al, 11b
	mov [edi], eax

	add edi, (0xC0 * 0x8)
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
	mov eax, 10000011b
	mov [edi], eax

	;; PDPTKernel
	mov edi, PDPTKernel
	mov eax, PDTKernel
	mov al, 11b
	mov [edi], eax

	;; PDTKernel
	mov edi, PDTKernel
	mov eax, 10000011b
	mov [edi], eax

	ret
