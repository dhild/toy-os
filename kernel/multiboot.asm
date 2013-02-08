global __start:function  	; making entry point visible to linker
extern __kernel_start, __kernel_data_end, __kernel_end
extern make_page_tables, PML4Tables
extern kmain, setup_interrupts, clearScreen
extern start_ctors, end_ctors, start_dtors, end_dtors

section .text
bits 32

	;; setting up the Multiboot header - see GRUB docs for details
	MODULEALIGN equ  1<<0	; align loaded modules on page boundaries
	MEMINFO     equ  1<<1	; provide memory map
	VIDEOINFO   equ  1<<2	; video information provided
	LOAD_KLUDGE equ  1<<16	; GRUB fails without these....
	FLAGS       equ  MODULEALIGN | MEMINFO | LOAD_KLUDGE | VIDEOINFO ; this is the Multiboot 'flag' field
	MAGIC       equ    0x1BADB002 ; 'magic number' lets bootloader find the header
	CHECKSUM    equ 0 -(MAGIC + FLAGS) ; checksum required

	align 4
MultiBootHeader:
	dd MAGIC
	dd FLAGS
	dd CHECKSUM
	dd MultiBootHeader   ; header_addr (flags[16])
	dd __kernel_start    ; load_addr (flags[16])
	dd __kernel_data_end ; load_end_addr (flags[16])
	dd __kernel_end      ; bss_end_addr (flags[16])
	dd __start           ; entry_addr (flags[16])
	dd 1                 ; mode type (flags[2])
	dd 0                 ; width (flags[2])
	dd 0                 ; height (flags[2])
	dd 0                 ; depth (flags[2])

	;; The temporary stack is a placeholder until 64-bit mode is entered.
	;; Then, a new stack is placed in 'high memory'.
	times 32 dd 0
TempStack:
hang:
	;; Halts the machine
	hlt
	jmp hang

__start:
	;; Keep interrupts disabled until we are set to handle them.
	cli

	;; Ensure that this is a multiboot load:
	cmp eax, 0x2BADB002
	jne hang

	;; Store the boot info structure
	mov ebp, ebx

	;; Temporarily set up the stack (we will do this again in 64-bit mode)
	mov esp, TempStack
	
	;; Set up for 64-bit mode
	mov eax, cr0		; 1. Disable paging, bit 31 of cr0
	and eax, 0x7FFFFFFF
	mov cr0, eax

	mov eax, cr4		; 2. Enable PAE, 6th bit of cr4
	or eax, 0x20
	mov cr4, eax

	call make_page_tables	; 3a. Prepare page tables

	mov eax, PML4Tables	; 3. Load cr3 with the physical address of the page table
	mov cr3, eax

	mov ecx, 0xC0000080	; 4. Enable IA-32e mode by setting IA32_EFER.LME = 1.
	rdmsr
	or eax, 0x00000100
	wrmsr

	mov eax, cr0		; 5. Enable paging, bit 31 of cr0
	or eax, 0x80000000
	mov cr0, eax

	;;  The change from compatibility to 64-bit mode, we need a fresh jump
	;;  using a 64-bit GDT pointer
	lgdt [GDT64.Pointer]		; Load the 64-bit global descriptor table.
	jmp KernelCodeSeg:Realm64	; Set the code segment and enter 64-bit long mode.
	;; Use 64-bit code from here on.
bits 64
Realm64:
	;; Reload all the segment registers:
	mov ax, KernelDataSeg
	mov ss, ax
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

	;; Load the task register:
	mov ax, TSSSeg
	ltr ax

	;; Initialize the stack pointer where we want it.
	mov rsp, stack.end

	;; Set up for the interrupts.
	;; The call itself should also enable them.
	mov rax, setup_interrupts
	call rax

	;; Run the C++ static constructors:
	;; 	mov r12, start_ctors
	;; 	mov r13, end_ctors
	;; .ctors_loop:
	;; 	cmp r12, r13
	;; 	je .ctors_done
	;; 	call r12
	;; 	add r12, 8
	;; 	jmp .ctors_loop
	;; .ctors_done:

	;; Call the kernel's main C++ function.
	;; 1st argument is the address of the multiboot structure:
	xor rdi, rdi
	mov edi, ebp
	mov rax, kmain
	call rax

	;; Run the C++ static destructors
	;; 	mov r12, start_dtors
	;; 	mov r13, end_dtors
	;; .dtors_loop:
	;; 	cmp r12, r13
	;; 	je .dtors_done
	;; 	call r12
	;; 	add r12, 8
	;; 	jmp .dtors_loop
	;; .dtors_done:

	;; If we manage to return, halt.
	jmp far KernelCodeSeg:hang

global KernelCodeSeg, KernelDataSeg

GDT64:			; Global Descriptor Table (64-bit).
NullSeg: equ $ - GDT64	; The null descriptor.
	dq 0		;
KernelCodeSeg: equ $ - GDT64	; The kernel code descriptor.
	dw 0xFFFF	; Limit (low)
	dw 0		; Base (low)
	db 0		; Base (middle)
	db 10011010B	; P | DPL | S | Type [Code | Conform | Read | Dirty]
	db 10101111B	; G | D/B | L | Avl | Limit (high)
	db 0		; Base (high)
KernelDataSeg: equ $ - GDT64	; The kernel data descriptor.
	dw 0xFFFF	; Limit (low)
	dw 0		; Base (low)
	db 0		; Base (middle)
	db 10010010B	; P | DPL | S | Type [Data | Exp-Dwn | Write | Dirty]
	db 10101111B	; G | D/B | L | Avl | Limit (high)
	db 0		; Base (high)

TSSSeg:	equ $ - GDT64		; The TSS Descriptor
	dw 0x67			; Limit (low)
	dw (TSS & 0xFFFF)	; Base (low)
	db ((TSS >> 16) & 0xFF)	; Base (mid1)
	db (0x89)		; P | DPL | 0 | Type (0x9: 64-bit TSS, avail)
	db 0			; G | 0 0 | AVL | Limit (high)
	db ((TSS >> 24) & 0xFF)	; Base (mid2)
	dd (TSS >> 32)		; Base (high)
	dd 0			; Reserved
	
.Pointer:			; The GDT-pointer.
	dw $ - GDT64 - 1	; Limit.
	dq GDT64		; Base.

	;; The TSS is required in 64-bit mode.
	;; However, only one is ever used.
TSS:	
	dd 0 			; Reserved
	dq 0			; RSP0
	dq 0			; RSP1
	dq 0			; RSP2
	dq 0			; Reserved
	dq endist1		; IST1
	dq endist2		; IST2
	dq endist3		; IST3
	dq endist4		; IST4
	dq endist5		; IST5
	dq endist6		; IST6
	dq endist7		; IST7
	dq 0			; Reserved
	dw 0			; Reserved
	dw 0xFFFF		; I/O Map base address.
.end:
	;; When the I/O Map base address is higher than the TSS limit,
	;; the I/O Map behaves as if all bits are set (access to I/O
	;; ports when CPL > 0 is not allowed.)
IOMap:
.end:

section .bss
	;; reserve initial kernel stack space
	STACKSIZE equ 0x4000	; that's 16kb
align 8
stack:
	   resb STACKSIZE	; reserve stack on a doubleword boundary
.end:
	;; The IST stacks are used with interrupts.
	;; They provide a fresh stack for interrupts to use.
	ISTSIZE equ 4096
	;; ist1 is used for NMI interrupts
ist1:
	resb ISTSIZE
endist1:
	;; ist2 is used for double fault interrupts
ist2:
	resb ISTSIZE
endist2:
	;; ist3 is used for Machine Check interrupts
ist3:
	resb ISTSIZE
endist3:
	;; ist4 is used for IRQs
ist4:
	resb ISTSIZE
endist4:
	;; ist5 is used for APIC interrupts
ist5:
	resb ISTSIZE
endist5:
ist6:
	resb ISTSIZE
endist6:
ist7:
	resb ISTSIZE
endist7: