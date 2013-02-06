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

	times 64 dd 0
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
	xchg bx, bx
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
	lgdt [GDT64.Pointer]	; Load the 64-bit global descriptor table.
	jmp KernelCodeSeg:Realm64	; Set the code segment and enter 64-bit long mode.; Use 64-bit.
bits 64
Realm64:
	mov ax, KernelDataSeg	; Set the A-register to the data descriptor.
	mov ss, ax
	mov ds, ax		; Set the data segment to the A-register.
	mov es, ax		; Set the extra segment to the A-register.
	mov fs, ax		; Set the F-segment to the A-register.
	mov gs, ax		; Set the G-segment to the A-register.

	;; Initialize the stack pointer where we want it.
	;; Technically, this is dangerous, since if there's an exception
	;; due to the stack, then we won't know until later when we enable
	;; the interrupts.
	mov rsp, stack.end

	;; Sets up for printing. We do this before interrupts so that we
	;; can print during the interrupt calls themselves.
	xchg bx, bx
	mov rax, clearScreen
	call rax

	;; Set up for the interrupts.
	;; The call itself should also enable them.
	mov rax, setup_interrupts
	call rax

	;; Store the boot information
	;mov rcx, (mb_info.end - mb_info)
	;xor rsi, rsi
	;mov esi, ebp
	;mov rdi, mb_info
	;rep movsb

	;; Run the C++ static constructors:
	mov r12, start_ctors
	mov r13, end_ctors
.ctors_loop:
	cmp r12, r13
	je .ctors_done
	call r12
	add r12, 8
	jmp .ctors_loop
.ctors_done:

	xor rdi, rdi
	mov edi, ebp
	mov rax, kmain
	call rax 		; Call the kernel proper

	;; Run the C++ static destructors
	mov r12, start_dtors
	mov r13, end_dtors
.dtors_loop:
	cmp r12, r13
	je .dtors_done
	call r12
	add r12, 8
	jmp .dtors_loop
.dtors_done:

.halt:
	cli
	hlt			; Halt if we manage to return
	jmp .halt

global KernelCodeSeg, KernelDataSeg

GDT64:				; Global Descriptor Table (64-bit).
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
	
.Pointer:			; The GDT-pointer.
	dw $ - GDT64 - 1	; Limit.
	dq GDT64		; Base.

IOMap:
	    times 32 db 0
	    db 0xFF

section .data
global mb_info, mb_info.flags, mb_info.mem_upper
mb_info:
.flags:
	dd 0
.mem_lower:
	dd 0
.mem_upper:
	dd 0
.boot_device:
	dd 0
.cmdline:
	dd 0
.mods_count:
	dd 0
.mods_addr:
	dd 0
.syms:
	times 4 dd 0
.mmap_length:
	dd 0
.mmap_addr:
	dd 0
.drives_length:
	dd 0
.drives_addr:
	dd 0
.config_table:
	dd 0
.boot_loader_name:
	dd 0
.apm_table:
	dd 0
.vbe_control_info:
	dd 0
.vbe_mode_info:
	dd 0
.vbe_mode:
	dw 0
.vbe_interface_seg:
	dw 0
.vbe_interface_off:
	dw 0
.vbe_interface_len:
	dw 0
.end:

section .bss
	;; reserve initial kernel stack space
	STACKSIZE equ 0x10000	; that's 64kb.
	align 4
stack:
	   resb STACKSIZE	; reserve stack on a doubleword boundary
.end:
