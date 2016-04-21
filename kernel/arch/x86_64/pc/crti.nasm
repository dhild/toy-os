bits 64
section .text
global __cxa_pure_virtual:function
__cxa_pure_virtual:
    ;; This is the function called if, somehow, a virtual call to a nonexistent function is made.
    ;; This *should* be impossible without hacking the virtual call table.
    jmp __cxa_pure_virtual

section .init
global _init:function
_init:
	push rbp
	mov rsp, rbp
	;; gcc will nicely put the contents of crtbegin.o's .init section here.

section .fini
global _fini:function
_fini:
	push rbp
	mov rsp, rbp
	;; gcc will nicely put the contents of crtbegin.o's .fini section here.
