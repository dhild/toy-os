global setup_interrupts:function
global set_interrupt:function
global set_trap:function

extern CodeSeg, DataSeg

%define breakpoint 		; xchg bx,bx

bits 64

section .data

table:
    times (256 * 2) dq 0
    .Pointer:        ; The IDT-pointer.
    dw $ - table - 1 ; Limit.
    dq table         ; Base.

section .text

; Sets up the interrupt tables with the basic interrupts defined as in
; interrupts.h. All other interrupts are blank.
; void setup_interrupts();
setup_interrupts:
    breakpoint
    cli

    mov rdi, table ; Set the tables to zero, as that indicates an absent
    xor rax, rax   ; interrupt handler.
    mov rcx, 512
    rep stosd

    ; Install the base interrupt handlers

    mov rdi, 0x00
    mov rsi, interrupt_0
    call set_interrupt

    mov rdi, 0x01
    mov rsi, interrupt_1
    call set_interrupt

    mov rdi, 0x02
    mov rsi, interrupt_2
    call set_interrupt

    mov rdi, 0x03
    mov rsi, interrupt_3
    call set_interrupt

    mov rdi, 0x04
    mov rsi, interrupt_4
    call set_interrupt

    mov rdi, 0x05
    mov rsi, interrupt_5
    call set_interrupt

    mov rdi, 0x06
    mov rsi, interrupt_6
    call set_interrupt

    mov rdi, 0x07
    mov rsi, interrupt_7
    call set_interrupt

    mov rdi, 0x08
    mov rsi, interrupt_8
    call set_interrupt

    mov rdi, 0x0A
    mov rsi, interrupt_10
    call set_interrupt

    mov rdi, 0x0B
    mov rsi, interrupt_11
    call set_interrupt

    mov rdi, 0x0C
    mov rsi, interrupt_12
    call set_interrupt

    mov rdi, 0x0D
    mov rsi, interrupt_13
    call set_interrupt

    mov rdi, 0x0E
    mov rsi, interrupt_14
    call set_interrupt

    mov rdi, 0xA0
    mov rsi, interrupt_16
    call set_interrupt

    mov rdi, 0xA1
    mov rsi, interrupt_17
    call set_interrupt

    mov rdi, 0xA2
    mov rsi, interrupt_18
    call set_interrupt

    mov rdi, 0xA3
    mov rsi, interrupt_19
    call set_interrupt

    breakpoint

    lidt [table.Pointer] ; Finally, enable the interrupts and return
    sti

    ret ; setup_interrupts

;struct idt_entry {
;    word offset1;
;    word segment;
;    byte ist;   0000_0xxx_b -> ?
;    byte flags; 1000_xxxx_b -> ?
;    word offset2;
;    dword offset3;
;    dword reserved;
;}

; void set_interrupt( byte number in rdi, void (*handler)() in rsi )
set_interrupt:

    mov rcx, 0xE ; Type: 64-bit interrupt gate

    jmp load_descriptor ; This will return to the caller when done

; void set_trap( byte number in rdi, void (*handler)() in rsi );
set_trap:
    mov rcx, 0xF ; Type: 64-bit trap gate

; Loads an interrupt descriptor
; Params:
;       rdi - interrupt number
;       rsi - handler pointer
;       rcx - type flag
load_descriptor:
    mov rax, rsi
    shr rax, 16
    shl rax, 1
    or rax, 0x1 ; Set the Present flag
    shl rax, 2
    and rdx, 0x3 ; Set the DPL (max value of 3)
    or rax, rdx
    shl rax, 5
    or rax, rcx ; Type of descriptor
    shl rax, 8 ; If IST is implemented, the descriptor part goes here
    shl rax, 16
    mov cx, CodeSeg
    or ax, cx ; Use the current cs segment selector - this only works in 64-bit mode!
    shl rax, 16
    or ax, si ; Load the lower part of the address

    and rdi, 0xFF ; convert rdi to address of descriptor
    shl rdi, 4    ; Each entry is 16 bytes long
    add rdi, table

    mov qword [rdi], rax

    mov rax, rsi
    sar rax, 32 ; IDT descriptor qword #2 has the top dword reserved, sign extended
    add rdi, 8

    mov qword [rdi], rax

    ret

extern divide_error_exception
extern debug_exception
extern nmi_interrupt
extern breakpoint_exception
extern overflow_exception
extern bound_range_exceeded_exception
extern invalid_opcode_exception
extern device_not_available_exception
extern double_fault_exception
extern invalid_tss_exception
extern segment_not_present_exception
extern stack_fault_exception
extern general_protection_exception
extern page_fault_exception
extern x87_fpu_floating_point_error
extern alignment_check_exception
extern machine_check_exception
extern simd_floating_point_exception

interrupt_0:
    call divide_error_exception
    iretq

interrupt_1:
    call debug_exception
    iretq

interrupt_2:
    call nmi_interrupt
    iretq

interrupt_3:
    call breakpoint_exception
    iretq

interrupt_4:
    call overflow_exception
    iretq

interrupt_5:
    call bound_range_exceeded_exception
    iretq

interrupt_6:
    call invalid_opcode_exception
    iretq

interrupt_7:
    call device_not_available_exception
    iretq

interrupt_8:
    call double_fault_exception
    iretq

interrupt_10:
    call invalid_tss_exception
    iretq

interrupt_11:
    call segment_not_present_exception
    iretq

interrupt_12:
    call stack_fault_exception
    iretq

interrupt_13:
    call general_protection_exception
    iretq

interrupt_14:
    call page_fault_exception
    iretq

interrupt_16:
    call x87_fpu_floating_point_error
    iretq

interrupt_17:
    call alignment_check_exception
    iretq

interrupt_18:
    call machine_check_exception
    iretq

interrupt_19:
    call simd_floating_point_exception
    iretq

