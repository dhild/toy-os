extern CODE_SEG_64
global setup_idt:function
extern handle_page_fault
bits 64

%define KERNEL_VIRTUAL_BASE 0xffffffff80000000

%define FLAG_INTERRUPT  0xe00
%define FLAG_TRAP       0xf00

%define FLAG_DPL0       0
%define FLAG_PRESENT    0x8000

%define IDT_ENTRIES     256

section .data

align 8
IDTR:
dw (IDTEND - IDT - 1)
dq IDT


align 8
IDT:
%assign i 0
%rep IDT_ENTRIES
    dd 0
    dd 0
    dd 0
    dd 0
%assign i i+1
%endrep
IDTEND:

section .text

ignored_interrupt:
    ; TODO: Add diagnostics for the ignored interrupt
    iret

ignored_interrupt_with_ec:
    ; TODO: Add diagnostics for the ignored interrupt
    add rsp, 8 ;; "pop" error code
    iret

global page_fault_interrupt:function
page_fault_interrupt:
    cli
    push rdi
    mov rdi, qword [rsp+8] ;; Error code
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rbp
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15

    mov rsi, cr2
    mov rax, handle_page_fault
    call rax

    pop r15
    pop r14
    pop r13
    pop r12
    pop r11
    pop r10
    pop r9
    pop r8
    pop rbp
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    pop rdi

    add rsp, 8 ;; "pop" error code
    iret



setup_idt:
    ;; rax - dword @b0 of IDT entry
    ;; rbx - dword @b4 of IDT entry
    ;; rdx - dword @b8 of IDT entry
    mov rbx, ignored_interrupt
    xor rax, rax
    mov ax, bx

    mov rbx, CODE_SEG_64
    shl rbx, 16
    or rax, rbx

    mov rcx, ignored_interrupt
    shr rcx, 16
    xor rbx, rbx
    mov bx, cx
    shl rbx, 32
    or rbx, (FLAG_INTERRUPT | FLAG_PRESENT | FLAG_DPL0)

    mov rcx, ignored_interrupt
    shr rcx, 32
    xor rdx, rdx
    mov edx, ecx

    mov rdi, IDT
    mov rcx, IDT_ENTRIES

.initialize:
    mov dword [rdi+0], eax
    mov dword [rdi+4], ebx
    mov dword [rdi+8], edx
    add rdi, 16
    dec rcx
    jne .initialize

    ;; Now, load specialty interrupts, using a special macro:

;; 1 = ISR number
;; 2 = ISR address
%macro set_interrupt 2
    mov rdi, IDT
    add rdi, (16 * %1)
    mov rax, %2
    and rax, 0xffff
    mov word [rdi], ax

    mov rax, %2
    shr rax, 16
    and rax, 0xffff
    mov word [rdi+6], ax

    mov rax, %2
    shr rax, 32
    mov dword [rdi+8], eax
%endmacro

    set_interrupt 10, ignored_interrupt_with_ec
    set_interrupt 11, ignored_interrupt_with_ec
    set_interrupt 12, ignored_interrupt_with_ec
    set_interrupt 13, ignored_interrupt_with_ec
    set_interrupt 17, ignored_interrupt_with_ec
    set_interrupt 30, ignored_interrupt_with_ec

    set_interrupt 14, page_fault_interrupt

    mov rax, IDTR
    lidt [rax]

    ret
