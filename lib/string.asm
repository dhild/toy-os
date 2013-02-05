;;global memcpy:function
;;global memset:function
;;global strlen:function
;;global strnlen:function

section .text
bits 64

;; void* memcpy(void* dest, void* src, size_t len)
;; rdi - dest
;; rsi - src
;; rdx - len
;; rax - return (the original dest)
;;memcpy:
	mov rax, rdi
	mov rcx, rdx
	cld
	rep movsb

	ret

;; void* memset(void* dest, int x, size_t len)
;; rdi - dest
;; rsi - x
;; rdx - len
;; rax - return (the original dest)
;;memset:
	mov r11, rdi
	mov rcx, rdx
	mov rax, rsi
	cld
	rep stosb

	mov rax, r11
	ret

;; size_t strlen(const char* str)
;; rdi - str
;; rax - return (the length of the C string)
;;strlen:
	xor rcx, rcx
	repne scasb
	not rcx
	sub rcx, 1
	mov rax, rcx
	ret

;; size_t strnlen(const char* str, size_t count)
;; rdi - str
;; rsi - count
;; rax - return (the length of the C string)
strnlen:
	xor rax, rax
.loop:
	cmp byte [rdi], 0
	jz .end
	dec rsi
	jz .end
	jmp .loop
.end:
	ret
