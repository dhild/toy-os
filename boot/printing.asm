global setup_printing
global clear_screen:function
global scroll_print:function
global puts:function
global putchar:function
section .data
bits 64

setup:
	db 0			; Has setup occured?
attribute:
	db 0x07			; light-grey on black
align 8
tabsize:
	dq 8
offset:
	dq 8			; Current offset
width:
	dq 80
height:
	dq 25
charSize:
	dq 2

	COLORBASEADDR equ 0xB8000
	MONOBAREADDR equ 0xB0000
BaseAddr:
	dq COLORBASEADDR

	
section .text
	
setup_printing:
	;; Prepares for printing. (Just clear the screen)

clear_screen:
	push rbx

	mov rsi, BaseAddr
	mov rdi, [rsi]
	mov rsi, width
	mov rcx, [rsi]
	mov rsi, height
	mov rbx, [rsi]
	mov rsi, charSize
	mov rax, [rsi]
	xor rdx, rdx
	mul rcx
	mul rbx
	mov rcx, rax
	xor rax, rax
	rep stosb

	mov rdi, offset
	mov [rdi], rax

	pop rbx
	ret

set_print_attribute:
	mov ax, di
	mov rdi, attribute
	mov [rdi], al
	ret
	
scroll_print:
	push rbx
	push r12

	mov r12, BaseAddr
	mov rdi, [r12]
	mov rsi, [r12]
	mov r12, width
	mov rax, [r12]
	xor rdx, rdx
	mov r12, charSize
	mul qword [r12]
	add rsi, rax
	mov rbx, rax
	mov r12, width
	mul qword [r12]
	sub rax, rbx
	mov rcx, rax
	shr rcx, 3
	rep movsq

	mov r12, offset
	mov rcx, [r12]
	cmp rcx, rdx
	jle .lowOffset
	sub rcx, rdx
	jmp .store
.lowOffset:
	xor rcx, rcx
.store:
	mov r12, offset
	mov [r12], rcx

	pop r12
	pop rbx
	ret

putchar:
	push rbx
	push r12

	mov rax, rdi

	;; Newline
	cmp al, 0x0A
	jne .testTab

	mov r12, offset
	mov rax, [r12]
	xor rdx, rdx
	mov r12, width
	div qword [r12]
	xor rdx, rdx
	mov r12, charSize
	div qword [r12]
	add rax, 1
	mul qword [r12]
	mov r12, width
	mul qword [r12]
	mov r12, offset
	mov [r12], rax
	jmp .exit

.testTab:
	;; Tab
	cmp al, 0x09
	jne .normalChar

	mov r12, offset
	mov rax, [r12]
	xor rdx, rdx
	mov r12, tabsize
	div qword [r12]
	add rax, 1
	mul qword [r12]
	mov r12, offset
	mov [r12], rax
	jmp .exit

.normalChar:
	mov r12, attribute
	mov rbx, [r12]
	mov ah, bl

	mov r12, BaseAddr
	mov rdi, [r12]
	mov r12, offset
	add rdi, [r12]

	mov [rdi], ax

	inc qword [r12]
	inc qword [r12]

.exit:
	;; If we need to scroll, do so.
	mov r12, charSize
	mov rax, [r12]
	xor rdx, rdx
	mov r12, width
	mul qword [r12]
	mov r12, height
	mul qword [r12]
	mov r12, offset
	cmp [r12], rax
	jle .noScroll
	call scroll_print
.noScroll:

	pop r12
	pop rbx
	ret

puts:
	push rbx		; Use preserved registers
	push r12
	mov r12, rdi
.loop:
	movzx bx, [r12]
	cmp bl, 0
	je .end

	mov rdi, rbx
	call print_char

	inc r12
	jmp .loop
.end:
	pop r12
	pop rbx
	ret
