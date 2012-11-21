global setup_interrupts:function
bits 64

extern KernelCodeSeg, interrupts
extern printf, handle_exception

section .data

align 8
recursion_flag:
	dq 0

panic_msg:
	db 'PANIC: early exception %02lx rip %lx:%lx error %lx cr2 %lx\n', 0

align 8
table:
	times (512) dd 0
.Pointer:			; The IDT-pointer.
	dw (256 * 16)		; Limit.
	dq table		; Base.

section .text

	;; Sets up the interrupt tables with the basic interrupts defined as in	
;; interrupts.h. All other interrupts are blank.
	;; void setup_interrupts();
setup_interrupts:
	;; Install the base interrupt handlers
	push rbx

%macro IDTentry 1
	;; Sets an interrupt descriptor
	;; dword 0: (31:16) segment selector
	;;          (15:00) offset 15:00
	;; dword 1: (31:16) offset 31:16
	;;          (15:08) P | DPL | 0 | Type
	;;          (08:00) 00000 | IST
	;; dword 2: (31:00) offset 63:32
	;; dword 3: (31:00) Reserved (sign extended of offset)

	;; Set rdi to point to the descriptor:
	mov rdi, %1
	shl rdi, 4
	mov rbx, table
	add rdi, rbx

	;; dword 0
	mov rbx, idt_handler
	mov word [rdi], bx
	mov rbx, KernelCodeSeg
	mov word [rdi+2], bx

	;; dword 1
	mov rax, idt_handler
	and eax, 0xFFFF0000
	or ax, 0x8E00
	mov dword [rdi+4], eax

	;; dword 2 and 3
	mov rbx, idt_handler
	shr rbx, 32
	mov qword [rdi+8], rbx
%endmacro

%assign i 0
%rep 256
	IDTentry i
%assign i i+1
%endrep
	
	;; Enable the interrupts and return
	mov rax, table.Pointer
	lidt [rax]

	sti
	pop rbx
	ret

idt_handler:
	cld
	lea rdx, [rel recursion_flag]
	cmp qword [rdx], 2
	jz halt_loop
	inc qword [rdx]

	;; Save registers
	push rax
	push rcx
	push rdx
	push rsi
	push rdi
	push r8
	push r9
	push r10
	push r11

	cmp word [rsp+96], KernelCodeSeg
	jne .panic

	lea rdi, [rsp+88]	; pointer to rip
	mov rax, handle_exception
	call rax
	and rax, rax
	jnz .panic

	pop r11
	pop r10
	pop r9
	pop r8
	pop rdi
	pop rsi
	pop rdx
	pop rcx
	pop rax

	add rsp, 16		; Drop vector number and error code
	dec qword [rel recursion_flag]
	iretq

.panic:
	mov r9, cr2
	mov r8, [rsp+80]	; Error code
	mov rsi, [rsp+72]	; Vector number
	mov rdx, [rsp+96]	; cs
	mov rcx, [rsp+88]	; rip
	xor eax, eax
	lea rdi, [rel panic_msg]
	mov rax, printf
	call rax
	
halt_loop:
	hlt
	jmp halt_loop
