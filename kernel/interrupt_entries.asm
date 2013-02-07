;; Entries into interrupt vectors are much better
;; when using pure assembly code. This is where
;; they are entered into.

section .text
bits 64

%macro savestackmods 0
	push r11
	push r10
	push r9
	push r8
	push rax
	push rcx
	push rdx
	push rsi
	push rdi
%endmacro

%macro restorestackmods 0
	pop rdi
	pop rsi
	pop rdx
	pop rcx
	pop rax
	pop r8
	pop r9
	pop r10
	pop r11
%endmacro

%macro savestackall 0
	push r15
	push r14
	push r13
	push r12
	push rbp
	push rbx

	savestackmods
%endmacro

%macro restorestackall 0
	restorestackmods
	
	pop rbx
	pop rbp
	pop r12
	pop r13
	pop r14
	pop r15
%endmacro

global interrupt0:function
global interrupt1:function
global interrupt2:function
global interrupt3:function
global interrupt4:function
global interrupt5:function
global interrupt6:function
global interrupt7:function
global interrupt8:function
global interrupt9:function
global interrupt10:function
global interrupt11:function
global interrupt12:function
global interrupt13:function
global interrupt14:function
global interrupt16:function
global interrupt17:function
global interrupt18:function
global interrupt19:function
global interruptIRQ0:function
global interruptIRQ1:function
global interruptIRQ2:function
global interruptIRQ3:function
global interruptIRQ4:function
global interruptIRQ5:function
global interruptIRQ6:function
global interruptIRQ7:function
global interruptIRQ8:function
global interruptIRQ9:function
global interruptIRQ10:function
global interruptIRQ11:function
global interruptIRQ12:function
global interruptIRQ13:function
global interruptIRQ14:function
global interruptIRQ15:function
global interruptNonspecific:function
global interruptSyscall:function
global interruptAPICTimer:function
global interruptAPICLINT0:function
global interruptAPICLINT1:function
global interruptAPICPerfMon:function
global interruptAPICThermal:function
global interruptAPICError:function
global interruptAPICSpurious:function


interrupt0:
interrupt1:
interrupt2:
interrupt3:
interrupt4:
interrupt5:
interrupt6:
interrupt7:
interrupt8:
interrupt9:
interrupt10:
interrupt11:
interrupt12:
interrupt13:
interrupt14:
interrupt16:
interrupt17:
interrupt18:
interrupt19:
interruptIRQ0:
interruptIRQ1:
interruptIRQ2:
interruptIRQ3:
interruptIRQ4:
interruptIRQ5:
interruptIRQ6:
interruptIRQ7:
interruptIRQ8:
interruptIRQ9:
interruptIRQ10:
interruptIRQ11:
interruptIRQ12:
interruptIRQ13:
interruptIRQ14:
interruptIRQ15:
interruptNonspecific:
interruptSyscall:
interruptAPICTimer:
interruptAPICLINT0:
interruptAPICLINT1:
interruptAPICPerfMon:
interruptAPICThermal:
interruptAPICError:
interruptAPICSpurious:
	iretq