global make_page_tables:function

section .text
bits 32
	
make_page_tables:
	;; PML4
	;; Entry 0, virtual address 0-0x8000000000
	;; Identity mapping
	;; Flags: !Accessed | !PCD | !PWT | !User | Read/write | Present
	mov edi, PML4Tables
	mov eax, PDPTIdentity
	mov al, 11b
	mov [edi], eax

	;; Entry 384, virtual address 0xFFFFC00000000000-0xFFFFC08000000000
	;; Kernel-space mapping to 0-0x8000000000
	;; Flags: !Accessed | !PCD | !PWT | !User | Read/write | Present
	mov edi, PML4Tables
	add edi, 0xC00
	mov eax, PDPTKernel
	mov al, 11b
	mov [edi], eax

	;; PDPTIdentity
	;; Entry 0, virtual address 0-0x40000000
	;; Identity mapping
	;; Flags: !PS | !Dirty | !Accessed | !PCD | !PWT | !User | Read/write | Present
	mov edi, PDPTIdentity
	mov eax, PDTIdentity
	mov al, 11b
	mov [edi], eax

	;; PDTIdentity
	;; Entry 0, virtual address 0-0x200000
	;; Identity mapping
	;; Flags: !PAT | !G | PS | !Dirty | !Accessed | !PCD | !PWT | !User | Read/write | Present
	mov edi, PDTIdentity
	xor eax, eax
	mov al, 10000011b
	mov [edi], eax

	;; PDPTKernel
	;; Entry 0, virtual address 0xFFFFC00000000000-0xFFFFC00040000000
	;; Kernel-space mapping to 0-0x40000000
	;; Flags: !PS | !Dirty | !Accessed | !PCD | !PWT | !User | Read/write | Present
	mov edi, PDPTKernel
	mov eax, PDTKernel
	mov al, 11b
	mov [edi], eax

	;; PDTKernel
	;; Entry 0, virtual address 0xFFFFC00000000000-0xFFFFC00000200000
	;; Kernel-space mapping to 0-0x200000
	;; Flags: !PAT | !G | PS | !Dirty | !Accessed | !PCD | !PWT | !User | Read/write | Present
	mov edi, PDTKernel
	xor eax, eax
	mov al, 10000011b
	mov [edi], eax

	;; Entry 1, virtual address 0xFFFFC00000200000-0xFFFFC00000400000
	;; Kernel-space mapping to 0x200000-0x400000
	;; Flags: !PAT | !G | PS | !Dirty | !Accessed | !PCD | !PWT | !User | Read/write | Present
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
