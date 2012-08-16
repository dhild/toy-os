global make_page_tables:function
global PML4Tables

section .bss
align 4096
PML4Tables:
	resb 4096
PDPTIdentity:
	resb 4096
PDTIdentity:
	resb 4096
PDPTKernel:
	resb 4096
PDTKernel:
	resb 4096
PTKernel:
	resb (251 * 4096)
PTEnd:
	
section .text
bits 32
	
	;;  All Intel processors since Pentium Pro (with exception of the Pentium M at 400 Mhz)
	;;  and all AMD since the Athlon series implement the Physical Address Extension (PAE).
	;;  This feature allows you to access up to 64 GB (2^36) of RAM. You can check for this
	;;  feature using CPUID. Once checked, you can activate this feature by setting bit 5
	;;  in CR4. Once active, the CR3 register points to a table of 4 64bit entries, each one
	;;  pointing to a page directory made of 4096 bytes (like in normal paging), divided
	;;  into 512 64bit entries, each pointing to a 4096 byte page table, divided into 512
	;;  64bit page entries.

panic:
	;; Trigger bochs breakpoint and halt
	xchg bx, bx
	hlt
	jmp panic
	
extern mb_info.flags, mb_info.mem_upper
make_page_tables:
	;; Zero out all tables
	mov edi, PML4Tables
	mov ecx, PTEnd
	sub ecx, PML4Tables
	xor eax, eax
	;; rep stosb

	;; PML4
	mov edi, PML4Tables
	mov eax, PDPTIdentity
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

	add eax, (2 * 1024 * 1024)
	mov [edi+8], eax

	ret

.multiboot:
	;; Check for a memory size from multiboot.
	mov eax, [ebp]
	and eax, 0x1
	cmp eax, 0x1
	jne .multiboot_mmap

	;; multiboot has a 'limit' address, in Kb, which is what we need, minus 1MB
	mov ecx, [ebp+8]
	add ecx, 0x400
	shr ecx, 2
	push ecx
	jmp .multiboot_mmap

.multiboot_mmap:
	;; Finally, try the mmap from multiboot
	jmp panic
