global GDTR, GDT, CODE_SEG_32, DATA_SEG, CODE_SEG_64
global fixup_gdtr:function
bits 32
section .text_early

;; This file sets up the GDT that we will use.
;; 
;; A GDT is a 64-bit entry, which looks like this:
;;  DW     SEG_LIMIT_LOW
;;  DW     BASE_ADDRESS_LOW
;;  DB     BASE_ADDRESS_MID
;;  DW     FLAGS
;;  DB     BASE_ADDRESS_HIGH
;;
;; The base address will always be 0 here, because paging will
;; control all physical-virtual mappings.
;;
;; The segment limit controls how much memory can be addressed.
;;
;; FLAGS = 15 14 13 12 11 10  09 08 07 06 05 04 03 02 01 00
;;          |  |  |  |  \         / |  \DPL/ S  \         /
;;          |  |  |  |   SEGMENT HI |         \    TYPE
;;          |  |  |  |              \- Present \- Descriptor type
;;          |  |  |  \- Available                 (0=system, 1=code/data)
;;          |  |  \- Long mode bit
;;          |  \- Default op size (0 for 16-bit, 1 for 32-bit)
;;          \- Granularity (0=size in bytes, 1=4k pages)
;;
;; 
;; For code descriptors, type is
;;  8 - Execute Only
;;  A - Executable / Readable
;;
;; For data descriptors, type is
;;  0 - Read Only
;;  2 - Read / Write
;;  4 - Expand Down RO
;;  6 - Expand Down RW
;;
;; Each of these types for code and data descriptors has an odd version to
;; indicating the accessed bit that we don't care about.
;;
;; DPL is a two bit field indicating which privilege level the descriptor is
;; in. 0 is the higher priority, 3 is the low priority. The kernel is in the
;; highest priority.
;;
;; Available is a bit unused by the processor.
;;
;; For long mode, the default op size must be 0.

%define FLAG_CODE 0xa
%define FLAG_DATA 0x2

%define FLAG_USER (1<<4)
%define FLAG_SYSTEM 0

%define FLAG_DPL0 0
%define FLAG_DPL1 (1 << 5)
%define FLAG_DPL2 (2 << 5)
%define FLAG_DPL3 (3 << 5)

%define FLAG_PRESENT (1 << 7)

%define FLAG_32   (1 << 14)
%define FLAG_LONG (1 << 13)

%define FLAG_G_4k (1 << 15)

%define FLAGS_COMMON (FLAG_USER | FLAG_DPL0 | FLAG_PRESENT | FLAG_G_4k)
%define FLAGS_CODE_32 (FLAG_CODE | FLAGS_COMMON | FLAG_32)
%define FLAGS_DATA_32 (FLAG_DATA | FLAGS_COMMON | FLAG_32)
%define FLAGS_CODE_64 (FLAG_CODE | FLAGS_COMMON | FLAG_LONG)

;; 1 = FLAGS, 2 = BASE, 3 = LIMIT
%macro GDTENTRY 3
    DW  ((%3) & 0xffff)
    DW  ((%2) & 0xffff)
    DB  (((%2) & 0xff0000) >> 16)
    DW  ((%1) | (((%3) & 0xf0000) >> 8))
    DB  (((%2) & 0xff000000) >> 24)
%endmacro

align 8
GDT:
    ;; Null descriptor
    GDTENTRY 0, 0, 0
CODE_SEG_32 EQU $-GDT ;; Defines the GDT offset for code32
    GDTENTRY FLAGS_CODE_32, 0, 0xfffff
DATA_SEG EQU $-GDT    ;; Defines the GDT offset for data (both)
    GDTENTRY FLAGS_DATA_32, 0, 0xfffff
CODE_SEG_64 EQU $-GDT
    GDTENTRY FLAGS_CODE_64, 0, 0xfffff
GDTEND:

align 8
GDTR:
    dw (GDTEND - GDT - 1)
    dq GDT ;; Ignored if not in long mode

bits 64
fixup_gdtr:
    mov rax, GDT
    add rax, 0xffffffff80000000

    mov qword [GDTR + 2], rax

    lgdt [GDTR]

    ret
