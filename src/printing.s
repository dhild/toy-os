global setup_printing:function
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

clear_screen:
	mov rdi, [BaseAddr]
	mov rcx, [width]
	mov rbx, [height]
	mov rax, [charSize]
	xor rdx, rdx
	mul rcx
	mul rbx
	mov rcx, rax
	xor rax, rax
	rep stosb

	mov [offset], rax

	ret

set_print_attribute:
	mov al, [esp+16]
	mov [attribute], al
	ret
	
scroll_print:
	push rdi
	push rsi
	push rax
	push rbx
	push rcx
	push rdx
	
	mov rdi, [BaseAddr]
	mov rsi, [BaseAddr]
	mov rax, [width]
	xor rdx, rdx
	mul qword [charSize]
	add rsi, rax
	mov rbx, rax
	mul qword [width]
	sub rax, rbx
	mov rcx, rax
	shr rcx, 3
	rep movsq

	mov rcx, [offset]
	cmp rcx, rdx
	jle .lowOffset
	sub rcx, rdx
	jmp .store
.lowOffset:
	xor rcx, rcx
.store:
	mov [offset], rcx

	pop rdx
	pop rcx
	pop rbx
	pop rax
	pop rsi
	pop rdi
	ret

print_char:
	push rsi
	push rax
	push rbx
	push rcx
	push rdx
	
	;; If we need to scroll, do so.
	mov rax, [charSize]
	xor rdx, rdx
	mul qword [width]
	mov rsi, rax
	mul qword [height]
	cmp [offset], rax
	jle .noScroll
	call scroll_print
.noScroll:
	
	mov rax, rdi

	;; Newline
	cmp al, 0x0A
	jne .testTab

	mov rax, [offset]
	xor rdx, rdx
	div rsi
	add rax, 1
	mul rsi
	mov [offset], rax
	jmp .exit

.testTab:
	;; Tab
	cmp al, 0x09
	jne .normalChar

	mov rcx, [tabsize]
	mov rax, [offset]
	xor rdx, rdx
	div rcx
	add rax, 1
	mul rcx
	mov [offset], rax
	jmp .exit

.normalChar:
	mov ah, [attribute]

	mov rdx, [BaseAddr]
	add rdx, [offset]

	mov [rdx], ax

	mov rdx, [offset]
	add rdx, 2
	mov [offset], rdx

.exit:
	pop rdx
	pop rcx
	pop rbx
	pop rax
	pop rsi
	ret

print_string:
	push rdi
	push rsi
	push rcx

	mov rsi, rdi
.loop:
	movzx cx, [rsi]
	cmp cl, 0
	je .end

	mov rdi, rcx
	call print_char
	
	inc rsi
	jmp .loop
.end:
	pop rcx
	pop rsi
	pop rdi
	ret
