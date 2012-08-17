global setup_printing
global clear_screen:function
global scroll_print:function
global print_string:function
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
	;; Prepares for printing.
	;; Basically, clear_screen without any stack movement.
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

	jmp r12

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

print_char:
	push rbx

	;; If we need to scroll, do so.
	mov rdi, charSize
	mov rax, [rdi]
	xor rdx, rdx
	mov rdi, width
	mul qword [rdi]
	mov rsi, rax
	mov rdi, height
	mul qword [rdi]
	mov rdi, offset
	cmp [rdi], rax
	jle .noScroll
	push rax
	push rdx
	push rsi
	call scroll_print
	pop rsi
	pop rdx
	pop rax
.noScroll:
	
	mov rax, rdi

	;; Newline
	cmp al, 0x0A
	jne .testTab

	mov rdi, offset
	mov rax, [rdi]
	xor rdx, rdx
	div rsi
	add rax, 1
	mul rsi
	mov [rdi], rax
	jmp .exit

.testTab:
	;; Tab
	cmp al, 0x09
	jne .normalChar

	mov rdi, tabsize
	mov rcx, [rdi]
	mov rdi, offset
	mov rax, [rdi]
	xor rdx, rdx
	div rcx
	add rax, 1
	mul rcx
	mov rdi, offset
	mov [rdi], rax
	jmp .exit

.normalChar:
	mov rdi, attribute
	mov ah, [rdi]

	mov rdi, BaseAddr
	mov rdx, [rdi]
	mov rdi, offset
	add rdx, [rdi]

	mov [rdx], ax

	mov rdi, offset
	mov rdx, [rdi]
	add rdx, 2
	mov [rdi], rdx

.exit:
	pop rbx
	ret

print_string:
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
