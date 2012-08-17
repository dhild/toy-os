global store_print_regs:function
extern print_string, print_hex

bits 64
section .bss

global interrupt_regs
global interrupt_regs.rax
global interrupt_regs.rbx
global interrupt_regs.rcx
global interrupt_regs.rdx
global interrupt_regs.rsp
global interrupt_regs.rbp
global interrupt_regs.rsi
global interrupt_regs.rdi
global interrupt_regs.r8
global interrupt_regs.r9
global interrupt_regs.r10
global interrupt_regs.r11
global interrupt_regs.r12
global interrupt_regs.r13
global interrupt_regs.r14
global interrupt_regs.r15
global interrupt_regs.ss
global interrupt_regs.rflags
global interrupt_regs.cs
global interrupt_regs.rip
global interrupt_regs.error
interrupt_regs:
.rax:
	resq 1
.rbx:
	resq 1
.rcx:
	resq 1
.rdx:
	resq 1
.rsp:
	resq 1
.rbp:
	resq 1
.rsi:
	resq 1
.rdi:
	resq 1
.r8:
	resq 1
.r9:
	resq 1
.r10:
	resq 1
.r11:
	resq 1
.r12:
	resq 1
.r13:
	resq 1
.r14:
	resq 1
.r15:
	resq 1
.ss:
	resq 1
.rflags:
	resq 1
.cs:
	resq 1
.rip:
	resq 1
.error:
	resq 1

section .text

store_print_regs:
	;; First, store the old r12.
	push rax
	mov rax, r12
	push r12
	mov r12, interrupt_regs.r12
	mov [r12], rax
	pop r12
	pop rax

%macro store_reg 2
	mov r12, %1
	mov [r12], %2
%endmacro

	store_reg interrupt_regs.rax, rax
	store_reg interrupt_regs.rbx, rbx
	store_reg interrupt_regs.rcx, rcx
	store_reg interrupt_regs.rdx, rdx
	store_reg interrupt_regs.rbp, rbp
	store_reg interrupt_regs.rsi, rsi
	store_reg interrupt_regs.rdi, rdi
	store_reg interrupt_regs.r8, r8
	store_reg interrupt_regs.r9, r9
	store_reg interrupt_regs.r10, r10
	store_reg interrupt_regs.r11, r11
	store_reg interrupt_regs.r13, r13
	store_reg interrupt_regs.r14, r14
	store_reg interrupt_regs.r15, r15

%unmacro store_reg 2
%macro store_reg 2
	mov r12, %1
	mov rax, %2
	mov [r12], rax
%endmacro

	push rbp
	mov rbp, rsp
	add rbp, 16
	store_reg interrupt_regs.ss, [rbp+40]
	store_reg interrupt_regs.rsp, [rbp+32]
	store_reg interrupt_regs.rflags, [rbp+24]
	store_reg interrupt_regs.cs, [rbp+16]
	store_reg interrupt_regs.rip, [rbp+8]
	store_reg interrupt_regs.error, [rbp+0]
	pop rbp

%macro print 2
	mov rdi, %1
	mov r12, print_string
	call r12
	mov rdi, %2
	mov r12, print_hex
	call r12
%endmacro

	print msg_error_code, interrupt_regs.error
	print msg_rax, interrupt_regs.rax
	print msg_rbx, interrupt_regs.rbx
	print msg_rcx, interrupt_regs.rcx
	print msg_rdx, interrupt_regs.rdx
	print msg_rsp, interrupt_regs.rsp
	print msg_rbp, interrupt_regs.rbp
	print msg_rdi, interrupt_regs.rdi
	print msg_rsi, interrupt_regs.rsi
	print msg_r8, interrupt_regs.r8
	print msg_r9, interrupt_regs.r9
	print msg_r10, interrupt_regs.r10
	print msg_r11, interrupt_regs.r11
	print msg_r12, interrupt_regs.r12
	print msg_r13, interrupt_regs.r13
	print msg_r14, interrupt_regs.r14
	print msg_r15, interrupt_regs.r15
	print msg_rip, interrupt_regs.rip
	print msg_rflags, interrupt_regs.rflags
	print msg_cs, interrupt_regs.cs
	print msg_ss, interrupt_regs.ss

	mov rdi, msg_last
	mov r12, print_string
	call r12

	ret

section .rodata
msg_error_code:
	db 'Error code: ',0xA,0
msg_rax:
	db 0xA,'Registers:',0xA,'rax: ',0
msg_rbx:
	db ', rbx: ',0
msg_rcx:
	db 0xA,'rcx: ',0
msg_rdx:
	db ', rdx: ',0
msg_rsp:
	db 0xA,'rsp: ',0
msg_rbp:
	db ', rbp: ',0
msg_rdi:
	db 0xA,'rdi: ',0
msg_rsi:
	db ', rsi: ',0
msg_r8:
	db 0xA,' r8: ',0
msg_r9:
	db ',  r9: ',0
msg_r10:
	db 0xA,'r10: ',0
msg_r11:
	db ', r11: ',0
msg_r12:
	db 0xA,'r12: ',0
msg_r13:
	db ', r13: ',0
msg_r14:
	db 0xA,'r14: ',0
msg_r15:
	db ', r15: ',0
msg_rip:
	db 0xA,'rip: ',0
msg_rflags:
	db ', rflags: ',0
msg_cs:
	db 0xA,'cs: ',0
msg_ss:
	db ', ss: ',0
msg_last:
	db 0xA,0