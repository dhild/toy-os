global make_page_tables:function
global PML4Tables
	
section .bss
	;; We can handle up to 4Gb. Translate that:
	MAXMEMSIZE equ 0x100000000
	MAX4KBPAGES equ (MAXMEMSIZE / 0x1000)
	MAX2MBPAGES equ (MAXMEMSIZE / 0x200000)
	MAX1GBPAGES equ (MAXMEMSIZE / 0x40000000)


	;; Each of these tables must be a multiple 4096 bytes long
	align 4096
PML4Tables:
	resq 512		; 1 entry per 512Gb

PDPTables:	
	resq 512		; 1 entry per 1Gb

PDTables:
	resq MAX2MBPAGES	; 1 entry per 2Mb

PTables:
	resq MAX4KBPAGES	; 1 entry per 4Kb
.end:
	
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
	;;  Set up basic paging.

	;; Unfortunately, BIOS calls only run in 16-bit mode =(
	jmp .multiboot
	;; First, we need to know how much memory is available. The BIOS interrupts should
	;; be active still, so let's try them first:
	xor cx, cx
	xor dx, dx
	mov ax, 0xE801
	sti
	int 0x15		; Requests the size of upper memory
	jc .bios2
	cmp ah, 0x86		; Operation unsupported
	je .bios2
	cmp ah, 0x80		; Invalid command
	je .bios2
	cli
	jcxz .useax		; Is cx/dx valid?

	mov ax, cx
	mov bx, dx
.useax:
	;; ax = number of contiguous Kb, 1M to 16M
	;; bx = contiguous 64Kb pages above 16M

	;; Find out if all the memory is contiguous
	cmp ax, 0x3C00
	jne .non_contiguous

	;; Memory IS congiguous, page all of it up to the hole
	xor ecx, ecx
	xor cx, bx
	add ecx, 0x100		; Add pages below 16M
	shl ecx, 4		; Convert to 4Kb pages

	;; Push the pages and set up the tables
	push ecx
	jmp SetupPML4Table

.non_contiguous:
	;; Uh-oh
	jmp panic
		
.bios2:
	;; Try BIOS interrupt #2
	xor ecx, ecx
	xor edx, edx
	mov ax, 0xE881
	int 0x15		; Requests the size of upper memory
	jc .multiboot
	cli
	cmp ah, 0x86		; Operation unsupported
	je .multiboot
	cmp ah, 0x80		; Invalid command
	je .multiboot
	jcxz .useax		; Is cx/dx valid?

	mov eax, ecx
	mov ebx, edx
	jmp .useax

.multiboot:
	;; Check for a memory size from multiboot.
	mov eax, [mb_info.flags]
	and eax, 0x1
	cmp eax, 0x1
	jne .multiboot_mmap

	;; multiboot has a 'limit' address, in Kb, which is what we need, minus 1MB
	mov ecx, [mb_info.mem_upper]
	add ecx, 0x400
	shr ecx, 2
	push ecx
	jmp SetupPML4Table

.multiboot_mmap:
	;; Finally, try the mmap from multiboot
	jmp panic


SetupPML4Table:
	;; We have three present entries:
	;; 0 - A privileged, r/w entry
	;; 1 - A user, r/w entry
	;; 2 - A user, read-only entry
	;; All three point to the same PDPT
	mov edi, PML4Tables
	mov eax, PDPTables
	or eax, 0x3
	xor ebx, ebx
	mov [edi], eax
	mov [edi+4], ebx
	add edi, 8
	or eax, 0x4
	mov [edi], eax
	mov [edi+4], ebx
	add edi, 8
	xor eax, 0x2
	mov [edi], eax
	mov [edi+4], ebx
	add edi, 8

	mov ecx, 509		; # of remaining entries
	shl ecx, 1
	xor eax, eax
	rep stosd

SetupPDPT:
	;; Each maps 1Gb
	;; We have three present entry groups:
	;; 0 - 4 privileged, r/w entries
	;; 1 - 4 user, r/w entries
	;; 2 - 4 user, read-only entries
	;; All three point to the same PDTs
	mov edi, PDPTables
	
	mov eax, PDTables
	or eax, 0x3
	xor ebx, ebx
	call .storeValues
	
	mov eax, PDTables
	or eax, 0x7
	xor ebx, ebx
	call .storeValues
	
	mov eax, PDTables
	or eax, 0x5
	xor ebx, ebx
	call .storeValues

	mov ecx, PDTables
	sub ecx, edi
	shr ecx, 2
	xor eax, eax
	rep stosd

	jmp SetupPDT
	
.storeValues:
	mov [edi], eax
	mov [edi+4], ebx
	add eax, 0x1000
	mov [edi+8], eax
	mov [edi+12], ebx
	add eax, 0x1000
	mov [edi+16], eax
	mov [edi+20], ebx
	add eax, 0x1000
	mov [edi+24], eax
	mov [edi+28], ebx
	add edi, 32
	ret

SetupPDT:
	;; The number of 4Kb pages is on the stack
	pop ecx
	push ecx
	add ecx, 0x1FF		; Just in case it's not mod 2 Mb
	shr ecx, 9		; Convert to number of 2 Mb pages

	mov edi, PDTables
	mov eax, PTables
	or eax, 0x7
	xor ebx, ebx
.loop:
	mov [edi], eax
	add eax, 0x1000
	mov [edi+4], ebx
	add edi, 8
	dec ecx
	jnz .loop

	mov ecx, PTables
	sub ecx, edi
	shr ecx, 2
	xor eax, eax
	rep stosd

SetupPT:
	;; The number of 4Kb pages is on the stack
	pop ecx

	mov edi, PTables
	xor eax, eax
	or eax, 0x7
	xor ebx, ebx
.loop:
	mov [edi], eax
	add eax, 0x1000
	mov [edi+4], ebx
	add edi, 8
	dec ecx
	jnz .loop

	mov ecx, PTables.end
	sub ecx, edi
	shr ecx, 2
	xor eax, eax
	rep stosd

	ret
