bits 64
section .text
global __cxa_pure_virtual:function
__cxa_pure_virtual:
    ;; This is the function called if, somehow, a virtual call to a nonexistent function is made.
    ;; This *should* be impossible without hacking the virtual call table.
    jmp __cxa_pure_virtual

section .init
global run_global_constructors:function
run_global_constructors:
	push rbp
	mov rbp, rsp
	;; gcc will nicely put the contents of crtbegin.o's .init section here.

section .fini
global run_global_destructors:function
run_global_destructors:
	push rbp
	mov rbp, rsp
	;; gcc will nicely put the contents of crtbegin.o's .fini section here.
