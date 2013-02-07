global setup_interrupts:function
bits 64

extern KernelCodeSeg
extern interrupt0
extern interrupt1
extern interrupt2
extern interrupt3
extern interrupt4
extern interrupt5
extern interrupt6
extern interrupt7
extern interrupt8
extern interrupt9
extern interrupt10
extern interrupt11
extern interrupt12
extern interrupt13
extern interrupt14
extern interrupt16
extern interrupt17
extern interrupt18
extern interrupt19
extern interruptIRQ0
extern interruptIRQ1
extern interruptIRQ2
extern interruptIRQ3
extern interruptIRQ4
extern interruptIRQ5
extern interruptIRQ6
extern interruptIRQ7
extern interruptIRQ8
extern interruptIRQ9
extern interruptIRQ10
extern interruptIRQ11
extern interruptIRQ12
extern interruptIRQ13
extern interruptIRQ14
extern interruptIRQ15
extern interruptNonspecific
extern interruptSyscall
extern interruptAPICTimer
extern interruptAPICLINT0
extern interruptAPICLINT1
extern interruptAPICPerfMon
extern interruptAPICThermal
extern interruptAPICError
extern interruptAPICSpurious

section .data

align 8
table:
%rep 256
	dd 0			; Reserved
	dd 0			; Offset
	dd 0			; Offset + flags
	dd 0			; Segment + offset
%endrep
.Pointer:			; The IDTpointer.
	dw (256 * 16)		; Limit.
	dq table		; Base.

section .text

	;; Sets up the interrupt tables with the basic interrupts defined as in	
	;; kernel/interrupts.h.
setup_interrupts:
	;; Install the base interrupt handlers
	push rbx

%macro IDTentry 2
	;; Sets an interrupt descriptor
	;; dword 0: (31:16) segment selector
	;;          (15:00) offset 15:00
	;; dword 1: (31:16) offset 31:16
	;;          (15:08) P | DPL | 0 | Type
	;;          (08:00) 00000 | IST
	;; dword 2: (31:00) offset 63:32
	;; dword 3: (31:00) Reserved (sign extended of offset)

	;; Set rdi to point to the descriptor:
	mov rdi, %1
	shl rdi, 4
	mov rbx, table
	add rdi, rbx

	;; dword 0
	mov rbx, %2
	mov word [rdi], bx
	mov rbx, KernelCodeSeg
	mov word [rdi+2], bx

	;; dword 1
	mov rax, %2
	and eax, 0xFFFF0000
	or ax, 0x8E00
	mov dword [rdi+4], eax

	;; dword 2 and 3
	mov rbx, %2
	shr rbx, 32
	mov qword [rdi+8], rbx
%endmacro

	IDTentry 0,  interrupt0
	IDTentry 1,  interrupt1
	IDTentry 2,  interrupt2
	IDTentry 3,  interrupt3
	IDTentry 4,  interrupt4
	IDTentry 5,  interrupt5
	IDTentry 6,  interrupt6
	IDTentry 7,  interrupt7
	IDTentry 8,  interrupt8
	IDTentry 9,  interrupt9
	IDTentry 10, interrupt10
	IDTentry 11, interrupt11
	IDTentry 12, interrupt12
	IDTentry 13, interrupt13
	IDTentry 14, interrupt14
	;; 15 is skipped in the docs, for some reason.
	IDTentry 16, interrupt16
	IDTentry 17, interrupt17
	IDTentry 18, interrupt18
	IDTentry 19, interrupt19

	;; 20-32 are also skipped. But I'm pretty sure they're reserved.

	IDTentry 32, interruptIRQ0
	IDTentry 33, interruptIRQ1
	IDTentry 34, interruptIRQ2
	IDTentry 35, interruptIRQ3
	IDTentry 36, interruptIRQ4
	IDTentry 37, interruptIRQ5
	IDTentry 38, interruptIRQ6
	IDTentry 39, interruptIRQ7
	IDTentry 40, interruptIRQ8
	IDTentry 41, interruptIRQ9
	IDTentry 42, interruptIRQ10
	IDTentry 43, interruptIRQ11
	IDTentry 44, interruptIRQ12
	IDTentry 45, interruptIRQ13
	IDTentry 46, interruptIRQ14
	IDTentry 47, interruptIRQ15
	
%assign i 48
%rep 16
	IDTentry i, interruptNonspecific
%assign i i+1
%endrep

	IDTentry 64, interruptSyscall
	
%assign i 65
%rep 190
	IDTentry i, interruptNonspecific
%assign i i+1
%endrep

	IDTentry 0xef, interruptAPICTimer
	IDTentry 0xf0, interruptAPICLINT0
	IDTentry 0xf1, interruptAPICLINT1
	IDTentry 0xf2, interruptAPICPerfMon
	IDTentry 0xfa, interruptAPICThermal
	IDTentry 0xfe, interruptAPICError
	IDTentry 0xff, interruptAPICSpurious
	
	;; Load the interrupt table
	mov rax, table.Pointer
	lidt [rax]

	;; After sti, the processor waits one instruction
	;; before interrupts are fully enabled. This is to
	;; prevent a processor from becoming too bogged down
	;; with interrupts: an sti, cli combo will not trigger
	;; an interrupt. However, we want to make sure we're
	;; not faulting on the pop instruction.
	;; We'll execute two *nearly* guaranteed non-faulting
	;; instructions, just in case.
	sti
	xchg rax, rax
	xchg rcx, rcx
	
	pop rbx
	ret
