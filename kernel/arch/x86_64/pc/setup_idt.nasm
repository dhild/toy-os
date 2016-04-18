extern CODE_SEG_64
global setup_idt:function
global fixup_idtr:function
bits 32
section .text_early

%define KERNEL_VIRTUAL_BASE 0xFFFFFFFF80000000

;; The IDT holds a set of descriptors, known as Interrupt, Call, and Trap gates.

%define FLAG_INTERRUPT  0xe
    
%define FLAG_DPL0    0
%define FLAG_PRESENT (1 << 7)

%define IDT_ENTRIES     256


;; 1 = ISR number
%macro ISR 1
isr%1:
    mov dx, %1
    jmp isr%1
%endmacro

ISRS:
%assign i 0
%rep IDT_ENTRIES
ISR i
%assign i (i+1)
%endrep

%define ISR_SIZE (isr1-isr0)


align 8
IDTR:
dw (IDTEND - IDT - 1)
dq IDT


align 8
IDT:
%assign i 0
%rep IDT_ENTRIES
    dd 0xdeadc0de
    dd 0xdeadc0de
    dd 0xdeadc0de
    dd 0xdeadc0de
%assign i i+1
%endrep
IDTEND:


setup_idt:
    ;; The virtual addresses are loaded & used
    ;; Interrupts are left disabled until the jump to long mode
    mov eax, IDT
    mov ebx, isr0
    or ebx, (KERNEL_VIRTUAL_BASE & 0xffffffff)

idt_init_one:
    ;; Target Low (word)
    mov ecx, ebx
    mov word [eax], cx
    add eax, 2

    ;; Code Selector (word)
    mov word[eax], CODE_SEG_64
    add eax, 2

    ;; IST (byte)
    mov byte[eax], 0
    add eax, 1

    ;; Flags (byte)
    mov byte[eax], (FLAG_PRESENT|FLAG_DPL0|FLAG_INTERRUPT)
    add eax, 1

    ;; Target High (word)
    shr ecx, 16
    mov word[eax], cx
    add eax, 2

    ;; Long Mode Target High 32
    mov dword[eax], (KERNEL_VIRTUAL_BASE >> 32)
    add eax, 4

    mov dword[eax], 0
    add eax, 4

    add ebx, ISR_SIZE

    cmp eax, IDTEND
    jl idt_init_one

    lidt[IDTR]
    ret

bits 64
fixup_idtr:
    mov rax, IDT
    add rax, 0xffffffff80000000

    mov qword [IDTR + 2], rax

    lidt[IDTR]

    ret

