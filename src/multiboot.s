global loader:function  	; making entry point visible to linker
extern kernel_begin_addr, end_of_data, end_of_kernel
extern make_page_tables, PML4Tables
	
	;; Breakpoint definition for gdb remote
	%define breakpoint 	; xchg bx,bx

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
	dd kernel_begin_addr ; load_addr (flags[16])
	dd end_of_data       ; load_end_addr (flags[16])
	dd end_of_kernel     ; bss_end_addr (flags[16])
	dd loader            ; entry_addr (flags[16])
	dd 1                 ; mode type (flags[2])
	dd 0                 ; width (flags[2])
	dd 0                 ; height (flags[2])
	dd 0                 ; depth (flags[2])

hang:
	;; Halts the machine
	xchg bx, bx
	hlt
	jmp hang

loader:
	;; Keep interrupts disabled until we are set to handle them.
	cli

	;; Ensure that this is a multiboot load:
	cmp eax, 0x2BADB002
	jne hang

	;; Store the boot info structure
	mov ecx, (mb_info.end - mb_info)
	mov esi, ebx
	lea edi, [mb_info]
	rep movsb
	
	;; Set up the stack and store the boot info struct address:
	mov esp, stack+STACKSIZE
	lea eax, [mb_info]
	xor ecx, ecx
	push eax
	push ecx

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

	call boot 		; Call the kernel proper

global NullSeg, CodeSeg, DataSeg, DPL1CodeSeg, DPL1DataSeg

GDT64:				; Global Descriptor Table (64-bit).
NullSeg: equ $ - GDT64	; The null descriptor.
	dq 0		;
CodeSeg: equ $ - GDT64	; The kernel code descriptor.
	dw 0xFFFF	; Limit (low)
	dw 0		; Base (low)
	db 0		; Base (middle)
	db 10011000B	; P | DPL | S | Type [Code | Conform | Read | Dirty]
	db 10101111B	; G | D/B | L | Avl | Limit (high)
	db 0		; Base (high)
DataSeg: equ $ - GDT64	; The kernel data descriptor.
	dw 0xFFFF	; Limit (low)
	dw 0		; Base (low)
	db 0		; Base (middle)
	db 10010010B	; P | DPL | S | Type [Data | Exp-Dwn | Write | Dirty]
	db 10101111B	; G | D/B | L | Avl | Limit (high)
	db 0		; Base (high)
DPL1CodeSeg: equ $ - GDT64  ; The dpl 1 code descriptor.
	dw 0xFFFF	; Limit (low)
	dw 0		; Base (low)
	db 0		; Base (middle)
	db 10111000B	; P | DPL | S | Type (Code, Execute-Only)
	db 10101111B	; G | D/B | L | Avl | Limit (high)
	db 0		; Base (high)
DPL1DataSeg: equ $ - GDT64  ; The dpl 1 data descriptor.
	dw 0xFFFF	; Limit (low)
	dw 0		; Base (low)
	db 0		; Base (middle)
	db 10110010B	; P | DPL | S | Type (Data, Read/Write)
	db 10101111B	; G | D/B | L | Avl | Limit (high)
	db 0		; Base (high)
DPL2CodeSeg: equ $ - GDT64  ; The dpl 2 code descriptor.
	dw 0xFFFF	; Limit (low)
	dw 0		; Base (low)
	db 0		; Base (middle)
	db 11011000B	; P | DPL | S | Type (Code, Execute-Only)
	db 10101111B	; G | D/B | L | Avl | Limit (high)
	db 0		; Base (high)
DPL2DataSeg: equ $ - GDT64  ; The dpl 2 data descriptor.
	dw 0xFFFF	; Limit (low)
	dw 0		; Base (low)
	db 0		; Base (middle)
	db 11010010B	; P | DPL | S | Type (Data, Read/Write)
	db 10101111B	; G | D/B | L | Avl | Limit (high)
	db 0		; Base (high)
DPL3CodeSeg: equ $ - GDT64  ; The dpl 3 code descriptor.
	dw 0xFFFF	; Limit (low)
	dw 0		; Base (low)
	db 0		; Base (middle)
	db 11111000B	; P | DPL | S | Type (Code, Execute-Only)
	db 10101111B	; G | D/B | L | Avl | Limit (high)
	db 0		; Base (high)
DPL3DataSeg: equ $ - GDT64  ; The dpl 3 data descriptor.
	dw 0xFFFF	; Limit (low)
	dw 0		; Base (low)
	db 0		; Base (middle)
	db 11110010B	; P | DPL | S | Type (Data, Read/Write)
	db 10101111B	; G | D/B | L | Avl | Limit (high)
	db 0		; Base (high)
	
.Pointer:			; The GDT-pointer.
	dw $ - GDT64 - 1	; Limit.
	dq GDT64		; Base.

IOMap:
	    times 32 db 0
	    db 0xFF

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
endstack:
