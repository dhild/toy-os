global _start:function  	; making entry point visible to linker
global GDT64, LDTSeg, KernelCodeSeg, KernelDataSeg, TSSSeg
extern entry64
global MultibootState

section .multiboot2
bits 32

	;; setting up the Multiboot 2 header - see GRUB docs for details
	MULTIBOOT2_MAGIC             equ  0xe85250d6
        MULTIBOOT2_ARCHITECTURE_I386 equ  0
        MULTIBOOT2_HEADER_SIZE       equ  (MultibootHeaderEnd - MultibootHeader)
        MULTIBOOT2_TAG_END           equ  0
        MULTIBOOT2_TAG_MBI_REQUEST   equ  1
        MULTIBOOT2_TAG_ADDRESS       equ  2
        MULTIBOOT2_TAG_ENTRY_ADDRESS equ  3
        MULTIBOOT2_TAG_FRAMEBUFFER   equ  5
        MULTIBOOT2_TAG_OPTIONAL      equ  1

	align 8
MultibootHeader:
	dd MULTIBOOT2_MAGIC
        dd MULTIBOOT2_ARCHITECTURE_I386
	dd MULTIBOOT2_HEADER_SIZE
        dd -(MULTIBOOT2_MAGIC + MULTIBOOT2_ARCHITECTURE_I386 + MULTIBOOT2_HEADER_SIZE)

mbi_tag:
        dw MULTIBOOT2_TAG_MBI_REQUEST
        dw 0
        dd (mbi_tag_end - mbi_tag)
        dd 9                    ; ELF Symbols
        dd 6                    ; Memory Map
        dd 2                    ; Boot loader name
        dd 8                    ; Framebuffer info
mbi_tag_end:
framebuffer_tag:
        dw MULTIBOOT2_TAG_FRAMEBUFFER   ; Tag ID
        dw MULTIBOOT2_TAG_OPTIONAL      ; Optional
        dd (framebuffer_tag_end - framebuffer_tag)
        dd 1024
        dd 768
        dd 32
framebuffer_tag_end:

        dw MULTIBOOT2_TAG_END           ; End Tag
        dw 0
        dd 8
MultibootHeaderEnd:
	;; The temporary stack is a placeholder until 64-bit mode is entered.
	;; Then, a new stack is placed in 'high memory'.
	times 32 dd 0
TempStack:
MultibootState:
        dd 0                    ; EAX
        dd 0                    ; EBX
hang:
	;; Halts the machine
	hlt
	jmp hang

_start:
	;; Keep interrupts disabled until we are set to handle them.
	cli

        mov ebp, MultibootState
        mov dword [ebp], eax
        mov dword [ebp + 4], ebx

	;; Temporarily set up the stack (we will do this again in 64-bit mode)
	mov esp, TempStack
	
	;; Set up for 64-bit mode
	mov eax, cr0		; 1. Disable paging, bit 31 of cr0
	and eax, 0x7FFFFFFF
	mov cr0, eax

	mov eax, cr4		; 2. Enable PAE, 6th bit of cr4
	or eax, 0010_0000b
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
	lgdt [GDT64Pointer]		; Load the 64-bit global descriptor table.
	jmp KernelCodeSeg:local64	; Set the code segment and enter 64-bit long mode.
	;; Use 64-bit code from here on.

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

bits 64
local64:
        mov rax, entry64
        jmp rax
        
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

LDTSeg:	equ $ - GDT64	; Dummy LDT descriptor
	dw 0		; Limit (0 - there are no entries.)
	dw 0		; Address (0)
	db 0		;
	db 10000010B	; P | DPL | S | Type [LDT]
	db 10100000B	; G | D/B | L | Avl | Limit (0)
	db 0		; Address (0)

TSSSeg:	equ $ - GDT64	; The TSS Descriptor
	dq 0		; This is set up in code.
	dq 0
	
GDT64Pointer:		; The GDT-pointer.
	dw $ - GDT64 - 1; Limit.
	dq GDT64	; Base.
        
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
PTEnd: