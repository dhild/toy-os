global loader:function  	; making entry point visible to linker
	extern kernel_begin_addr, end_of_data, end_of_kernel

	;; Breakpoint definition for gdb remote
	%define breakpoint 	; xchg bx,bx

	section .text

	bits 32

loader:
	;; Keep interrupts disabled until we are set to handle them.
	cli

	;; Ensure that this is a multiboot load:
	cmp eax, 0x2BADB002
	jne hang
	
	;; Set up the stack and store the boot info struct:
	mov esp, stack+STACKSIZE

	mov esi, ebx
	mov edi, boot_info
	mov ecx, BOOT_INFO_SIZE
	rep movsb

	breakpoint

 	;; Note: this cannot be a call, as we would push a 32-bit pointer.
	;;  If we tried to return, it should crash as we'll be in 64-bit
	;;  mode, expecting a 64-bit pointer.....
	jmp setup64

hang:
	;; Halts the machine
	hlt
	jmp hang


	;;
	;; debug:
	;;    mov word [esi], 0x2a30
	;;    add esi, 2
	;;    ret

	;; All Intel processors since Pentium Pro (with exception of the Pentium M at 400 Mhz)
	;;  and all AMD since the Athlon series implement the Physical Address Extension (PAE).
	;;  This feature allows you to access up to 64 GB (2^36) of RAM. You can check for this
	;;  feature using CPUID. Once checked, you can activate this feature by setting bit 5
	;;  in CR4. Once active, the CR3 register points to a table of 4 64bit entries, each one
	;;  pointing to a page directory made of 4096 bytes (like in normal paging), divided
	;;  into 512 64bit entries, each pointing to a 4096 byte page table, divided into 512
	;;  64bit page entries.

make_paging:
	;;  Set up basic paging.
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

setup64:
	mov eax, cr0 	; 1. Disable paging, 32nd bit of cr0
	and eax, 0x7FFFFFFF
	mov cr0, eax

	mov eax, cr4   	; 2. Enable PAE, 6th bit of cr4
	or eax, 100000b
	mov cr4, eax

	call make_paging 	; 3a. Prepare paging

	mov eax, 0x1000 	; 3. Load cr3 with the physical address of the page table
	mov cr3, eax

	mov ecx, 0xC0000080 ; 4. Enable IA-32e mode by setting IA32_EFER.LME = 1.
	rdmsr
	or eax, 0x00000100
	wrmsr

	mov eax, cr0 	; 5. Enable paging, 31st bit of cr0
	or eax, 0x80000000
	mov cr0, eax

	;;  The change from compatibility to 64-bit mode, we need a fresh jump
	;;  using a 64-bit GDT pointer
	lgdt [GDT64.Pointer] ; Load the 64-bit global descriptor table.
	;;     jmp Realm64
	jmp CodeSeg:Realm64 ; Set the code segment and enter 64-bit long mode.; Use 64-bit.

	;; Now we're in 64-bit mode!
	bits 64
	extern boot             ; boot is defined elsewhere
Realm64:
	cli			; Clear the interrupt flag.
	mov ax, DataSeg	; Set the A-register to the data descriptor.
	mov ss, ax
	mov ds, ax		; Set the data segment to the A-register.
	mov es, ax		; Set the extra segment to the A-register.
	mov fs, ax		; Set the F-segment to the A-register.
	mov gs, ax		; Set the G-segment to the A-register.
	mov edi, 0xB8000	; Set the destination index to 0xB8000.
	mov rax, 0x1F201F201F201F20	; Set the A-register to 0x1F201F201F201F20.
	mov ecx, 500		; Set the C-register to 500.
	rep movsq			; Clear the screen.

	breakpoint

	;;     ltr TSSSeg

	call boot 		; Call the kernel proper


	
	align 32
pdpt:
	times 4 dq 0

	extern end_of_kernel
	
	global NullSeg, CodeSeg, DataSeg, DPL1CodeSeg, DPL1DataSeg

GDT64:				; Global Descriptor Table (64-bit).
NullSeg:	 equ $ - GDT64	; The null descriptor.
	    dq 0		;
CodeSeg:	 equ $ - GDT64	; The code descriptor.
	    dw 0		; Limit (low)
	    dw 0		; Base (low)
	    db 0		; Base (middle)
	    db 10011000b	; P | DPL | S | Type (Code, Execute-Only)
	    db 00100000b	; G | D/B | L | Avl | Limit (high)
	    db 0		; Base (high)
DataSeg:	 equ $ - GDT64	; The data descriptor.
	    dw 0		; Limit (low)
	    dw 0		; Base (low)
	    db 0		; Base (middle)
	    db 10010010b	; P | DPL | S | Type (Data, Read/Write)
	    db 00100000b	; G | D/B | L | Avl | Limit (high)
	    db 0		; Base (high)
DPL1CodeSeg:	 equ $ - GDT64  ; The dpl 1 code descriptor.
	    dw 0		; Limit (low)
	    dw 0		; Base (low)
	    db 0		; Base (middle)
	    db 10111000b	; P | DPL | S | Type (Code, Execute-Only)
	    db 00100000b	; G | D/B | L | Avl | Limit (high)
	    db 0		; Base (high)
DPL1DataSeg:	 equ $ - GDT64  ; The dpl 1 data descriptor.
	    dw 0		; Limit (low)
	    dw 0		; Base (low)
	    db 0		; Base (middle)
	    db 10110010b	; P | DPL | S | Type (Data, Read/Write)
	    db 00100000b	; G | D/B | L | Avl | Limit (high)
	    db 0		; Base (high)
DPL2CodeSeg:	 equ $ - GDT64  ; The dpl 2 code descriptor.
	    dw 0		; Limit (low)
	    dw 0		; Base (low)
	    db 0		; Base (middle)
	    db 11011000b	; P | DPL | S | Type (Code, Execute-Only)
	    db 00100000b	; G | D/B | L | Avl | Limit (high)
	    db 0		; Base (high)
DPL2DataSeg:	 equ $ - GDT64  ; The dpl 2 data descriptor.
	    dw 0		; Limit (low)
	    dw 0		; Base (low)
	    db 0		; Base (middle)
	    db 11010010b	; P | DPL | S | Type (Data, Read/Write)
	    db 00100000b	; G | D/B | L | Avl | Limit (high)
	    db 0		; Base (high)
DPL3CodeSeg:	 equ $ - GDT64  ; The dpl 3 code descriptor.
	    dw 0		; Limit (low)
	    dw 0		; Base (low)
	    db 0		; Base (middle)
	    db 11111000b	; P | DPL | S | Type (Code, Execute-Only)
	    db 00100000b	; G | D/B | L | Avl | Limit (high)
	    db 0		; Base (high)
DPL3DataSeg:	 equ $ - GDT64  ; The dpl 3 data descriptor.
	    dw 0		; Limit (low)
	    dw 0		; Base (low)
	    db 0		; Base (middle)
	    db 11110010b	; P | DPL | S | Type (Data, Read/Write)
	    db 00100000b	; G | D/B | L | Avl | Limit (high)
	    db 0		; Base (high)
	;;     TSSSeg: equ $ - GDT64       ; Used for the TSS
	;;     dw (TSS.end - TSS) & 0xFFFF ; Limit
	;;     dw (TSS & 0xFFFF)
	;;     db ((TSS >> 16) & 0xFF)
	;;     db 0x89
	;;     db (((TSS.end - TSS) >> 16) & 0xF) | 0x80
	;;     dq ((TSS >> 24) & 0xFFFFFFFFFF)
	;;     db 0
	;;     dw 0
	    .Pointer:		; The GDT-pointer.
	    dw $ - GDT64 - 1	; Limit.
	    dq GDT64		; Base.

TSS:
	    dd 0 		; Reserved
	    dq (endstack - 0x100)
	    dq 0
	    dq 0
	    dq 0 		; Reserved
	    times 7 dq 0
	    dq 0 		; Reserved
	    dw 0 		; Reserved
	    dw (IOMap - TSS)
	.end:

IOMap:
	    times 32 db 0
	    db 0xFF

	;;  reserve initial kernel stack space
	STACKSIZE equ 0x4000	; that's 16kb.

	section .bss
	align 4

stack:
	   resb STACKSIZE	; reserve 16k stack on a doubleword boundary

endstack:

	;; Reserve the length of the info struct
	BOOT_INFO_SIZE equ 90

	align 4
	
boot_info:
	resb BOOT_INFO_SIZE