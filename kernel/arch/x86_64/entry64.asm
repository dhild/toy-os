bits 64
global entry64:function
extern GDT64, LDTSeg, KernelCodeSeg, KernelDataSeg, TSSSeg
extern kernel_early, _init, setup_interrupts, kernel_main
extern MultibootState

section .text

entry64:
	;; Reload all the segment registers:
	mov ax, KernelDataSeg
	mov ss, ax
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

	;; Initialize the stack pointer where we want it.
	mov rsp, stack.end

	mov ax, LDTSeg
	lldt ax

	;; 
	;; Set up the TSS segment descriptor:
	;;
        mov rax, GDT64
	mov rdi, TSSSeg
        add rdi, rax
	;; First the limit bits
	mov rax, (TSS.end - TSS)
	mov word [rdi], ax
	shr rax, 16
	mov byte [rdi+6], al
	;; Next, the base address bits
	mov rax, TSS
	mov word [rdi+2], ax
	shr rax, 16
	mov byte [rdi+4], al
	shr rax, 8
	mov byte [rdi+7], al
	shr rax, 8
	mov dword [rdi+8], eax
	;; And finally, the flags:
	;; (Technically, byte 7 also has the G and AVL flags.
	;;  For our purposes, we ignore them.)
	mov al, 1000_1001b
	mov byte [rdi+5], al

	;; Now, load the task register:
	mov ax, TSSSeg
	ltr ax

        ;; Set up stack for calls:
        sub rsp, 128            ; "Red Zone" - see System V ABI
        
	;; 
	;; Set up for the interrupts.
	;; 
	mov rax, setup_interrupts
	call rax
        
	;; Initialize the core kernel before running the global constructors.
        mov rax, kernel_early
	call rax

        ;; Call the global constructors.
	mov rax, _init
        call rax

	;; 
        ;; Transfer control to the main kernel.
	;; 1st argument is the multiboot "magic" number.
       	;; 2nd argument is the address of the multiboot structure
	;; 
        xor rbp, rbp
        mov ebp, MultibootState
	xor rdi, rdi
        mov dword edi, [rbp]
	xor rsi, rsi
        mov dword esi, [rbp + 4]
	mov rax, kernel_main
        call rax

	;; If we manage to return, halt.
hang:
	hlt
	jmp hang

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
	;; When the I/O Map base address is higher than the TSS limit,
	;; the I/O Map behaves as if all bits are set (access to I/O
	;; ports when CPL > 0 is not allowed.)
.IOMap:
.end:

section .bss
	;; The IST stacks are used with interrupts.
	;; They provide a fresh stack for interrupts to use.
	ISTSIZE equ 4096
	;; ist1 is used for NMI interrupts
align 4096
ist1:
	resb ISTSIZE
endist1:
	;; ist2 is used for double fault interrupts
ist2:
	resb ISTSIZE
endist2:
	;; ist3 is used for machine check exceptions
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
	;; ist6 is used for stack seg faults
ist6:
	resb ISTSIZE
endist6:
ist7:
	resb ISTSIZE
endist7:

	;; reserve initial kernel stack space
	STACKSIZE equ (16 * 1024 * 1024) ; that's 16kb
align 4096
stack:
	   resb STACKSIZE	; reserve stack
.end:
