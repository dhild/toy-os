global make_page_tables:function

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

extern mb_info.flags, mb_info.mem_upper
make_page_tables:
	;;  Set up basic paging.

	;; Check for a memory size from multiboot.
	;; Once found, put it in ecx.
	mov eax, [mb_info.flags]
	and eax, 0x1
	cmp eax, 0x1
	jne .mmap_parse

	;; multiboot has a 'limit' address, which is what we need, minus 1MB
	mov ecx, [mb_info.mem_upper]
	add ecx, 0x100000
	jmp .have_mem_count

.mmap_parse:

.have_mem_count:
	

	
	;;  This is a basic page table that is only used until the 64-bit version
	;;  called from the C++ code can be loaded....
	mov edi, 0x1000    	; Set the destination index to 0x1000.
	mov cr3, edi       	; Set control register 3 to the destination index.
	xor eax, eax       	; Nullify the A-register.
	mov ecx, 4096      	; Set the C-register to 4096.
	rep stosd          	; Clear the memory.
	mov edi, cr3       	; Set the destination index to control register 3.

	mov DWORD [edi], 0x2003 ; Set the double word at the destination index to 0x2003.
	add edi, 0x1000	    ; Add 0x1000 to the destination index.
	mov DWORD [edi], 0x3003 ; Set the double word at the destination index to 0x3003.
	add edi, 0x1000	    ; Add 0x1000 to the destination index.
	mov DWORD [edi], 0x4003 ; Set the double word at the destination index to 0x4003.
	add edi, 0x1000	    ; Add 0x1000 to the destination index.

	mov ebx, 0x00000003	; Set the B-register to 0x00000003.
	mov ecx, 512	; Set the C-register to 512.

.SetEntry:
	mov DWORD [edi], ebx ; Set the double word at the destination index to the B-register.
	add ebx, 0x1000	 ; Add 0x1000 to the B-register.
	add edi, 8		 ; Add eight to the destination index.
	loop .SetEntry	 ; Set the next entry.

	ret
