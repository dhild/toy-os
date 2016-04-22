global kernel_entry:function  	; making entry point visible to linker
global CODE_SEG_64
extern setup_idt, setup_paging
extern fixup_idtr, fixup_paging
extern kernel_start, kernel_end, kernel_physical_start, kernel_physical_end
extern header_signature_addr, stack_physical_end, kernel_bss_start
extern kernel_main, run_global_constructors, run_global_destructors
bits 32

%define KERNEL_VIRTUAL_BASE 0xffffffff80000000

section .header_signature

%define MB_MAGIC 0x1badb002
%define MB_MEMINFO (1 << 1)
%define MB_VIDINFO (1 << 2)
%define MB_ADDRS   (1 << 16)
%define MB_FLAGS (MB_MEMINFO | MB_VIDINFO | MB_ADDRS)
%define MB_CHECKSUM -(MB_MAGIC + MB_FLAGS)

align 4
MultibootHeader:
    dd 0x1badb002
    dd MB_FLAGS
    dd MB_CHECKSUM
    dd header_signature_addr
    dd kernel_physical_start
    dd kernel_physical_end
    dd 0
    dd kernel_entry
    dd 0        ; Graphics mode
    dd 1024     ; width
    dd 768      ; height
    dd 32       ; depth


%define MULTIBOOT2_HEADER_MAGIC         0xe85250d6
%define MULTIBOOT2_BOOTLOADER_MAGIC     0x36d76289
%define MULTIBOOT_INFO_ALIGN            0x00000008
%define MULTIBOOT_TAG_ALIGN                  8
%define MULTIBOOT_TAG_TYPE_END               0
%define MULTIBOOT_TAG_TYPE_CMDLINE           1
%define MULTIBOOT_TAG_TYPE_BOOT_LOADER_NAME  2
%define MULTIBOOT_TAG_TYPE_MODULE            3
%define MULTIBOOT_TAG_TYPE_BASIC_MEMINFO     4
%define MULTIBOOT_TAG_TYPE_BOOTDEV           5
%define MULTIBOOT_TAG_TYPE_MMAP              6
%define MULTIBOOT_TAG_TYPE_VBE               7
%define MULTIBOOT_TAG_TYPE_FRAMEBUFFER       8
%define MULTIBOOT_TAG_TYPE_ELF_SECTIONS      9
%define MULTIBOOT_TAG_TYPE_APM               10
%define MULTIBOOT_TAG_TYPE_EFI32             11
%define MULTIBOOT_TAG_TYPE_EFI64             12
%define MULTIBOOT_TAG_TYPE_SMBIOS            13
%define MULTIBOOT_TAG_TYPE_ACPI_OLD          14
%define MULTIBOOT_TAG_TYPE_ACPI_NEW          15
%define MULTIBOOT_TAG_TYPE_NETWORK           16
%define MULTIBOOT_TAG_TYPE_EFI_MMAP          17
%define MULTIBOOT_TAG_TYPE_EFI_BS            18
%define MULTIBOOT_HEADER_TAG_END  0
%define MULTIBOOT_HEADER_TAG_INFORMATION_REQUEST  1
%define MULTIBOOT_HEADER_TAG_ADDRESS  2
%define MULTIBOOT_HEADER_TAG_ENTRY_ADDRESS  3
%define MULTIBOOT_HEADER_TAG_CONSOLE_FLAGS  4
%define MULTIBOOT_HEADER_TAG_FRAMEBUFFER  5
%define MULTIBOOT_HEADER_TAG_MODULE_ALIGN  6
%define MULTIBOOT_HEADER_TAG_EFI_BS        7
%define MULTIBOOT_ARCHITECTURE_I386  0
%define MULTIBOOT_ARCHITECTURE_MIPS32  4
%define MULTIBOOT_HEADER_TAG_OPTIONAL 1
%define MULTIBOOT_CONSOLE_FLAGS_CONSOLE_REQUIRED 1
%define MULTIBOOT_CONSOLE_FLAGS_EGA_TEXT_SUPPORTED 2


align MULTIBOOT_INFO_ALIGN

Multiboot2Header:

    dd MULTIBOOT2_HEADER_MAGIC
    dd MULTIBOOT_ARCHITECTURE_I386
    dd (Multiboot2HeaderEnd - Multiboot2Header)
    dd 0x100000000 - (MULTIBOOT2_HEADER_MAGIC + MULTIBOOT_ARCHITECTURE_I386 + (Multiboot2HeaderEnd - Multiboot2Header))

align MULTIBOOT_TAG_ALIGN
TagFB:
    dw MULTIBOOT_HEADER_TAG_FRAMEBUFFER
    dw MULTIBOOT_HEADER_TAG_OPTIONAL
    dd (.end - TagFB)
    dd 1024     ; width
    dd 768      ; height
    dd 32       ; depth
.end:

align MULTIBOOT_TAG_ALIGN
TagEnd:
    dw MULTIBOOT_HEADER_TAG_END
    dw 0
    dd (.end - TagEnd)
.end:

align MULTIBOOT_TAG_ALIGN
Multiboot2HeaderEnd:


Multiboot2SaveRegs:
.eax:
    dd 0
.ebx:
    dd 0

section .text_early

kernel_entry:
    ;; Keep interrupts disabled until we are set to handle them.
    cli

    lgdt [GDTR]

    ; Clear potentially stale segment registers:
    mov edx, DATA_SEG
    mov ds, edx
    mov es, edx
    mov fs, edx
    mov gs, edx

    ;; Load ss:esp in one instruction (intel recommended method, prevents mid-load exceptions)
    lss esp, [stack_pointer]
    sub esp, 8
    mov ebp, esp

    ;; Reload the code segment
    jmp CODE_SEG_32:hosted_gdt

stack_pointer:
    dd stack_physical_end
    dw DATA_SEG

hosted_gdt:

    cmp eax, MULTIBOOT2_BOOTLOADER_MAGIC
    jne fail2boot

    mov dword [Multiboot2SaveRegs.eax], eax

.copy_mb2_to_safe:

    mov dword [Multiboot2SaveRegs.ebx], kernel_physical_end

    mov edi, kernel_physical_end
    mov esi, ebx            ; Address of multiboot2 structure
    mov ecx, dword [ebx]    ; Size of multiboot2 tags, round up
    add ecx, 3
    shr ecx, 2

    cld
    rep movsd               ; Copy multiboot2 tags to end of kernel

    mov ebx, edi
    add ebx, 8              ; Make sure the paging routine starts AFTER the multiboot structure

setupLongMode:
    ;; Set up for 64-bit mode

    ; 1. Setup an IDT (preserve ebx for paging routine)
    push ebx
    call setup_idt
    pop ebx

    ; 2. Disable paging, bit 31 of cr0
    mov eax, cr0
    and eax, 0x7FFFFFFF
    mov cr0, eax

    ; 3. Initialize paging tables. First safe address is in ebx at call, PML4 address is in ebx after return
    call setup_paging

    ; 4. Load cr3 with the physical address of the page table
    mov cr3, ebx

    ; 5. Enable PAE, 6th bit of cr4
    mov eax, cr4
    or eax, 0010_0000b
    mov cr4, eax

    ; 6. Enable IA-32e mode by setting IA32_EFER.LME = 1.
    mov ecx, 0xC0000080
    rdmsr
    or eax, (1 << 8)
    wrmsr

    ; 7. Enable paging, bit 31 of cr0
    mov eax, cr0
    or eax, (1 << 31)
    mov cr0, eax

    ;;  The change from compatibility to 64-bit mode, we need a fresh jump
    ;;  using a 64-bit GDT pointer
    jmp CODE_SEG_64:cleanup_32

bits 64

cleanup_32:
    ;; Jump to the higher-half address:
    mov rax, KERNEL_VIRTUAL_BASE
    add rax, cleanup_64
    jmp rax

cleanup_64:

    ;; Fix the stack
    mov rax, (kernel_start - 8)
    mov rsp, rax
    mov rbp, rax

    ; Move GDTR / IDTR addresses to their virtual ones
    call fixup_gdtr
    call fixup_idtr

    ; After that, fix the paging entries by removing the
    ; virtual <=> physical mapping
    call fixup_paging

    ; Initialize the multiboot info:
    call initialize_mb2

    ; Setup for C++ by running the global constructors:
    mov rax, run_global_constructors
    call rax

    ; Call the kernel's main entry
    mov rax, kernel_main
    call rax

    ; Teardown for C++ by running the global destructors:
    mov rax, run_global_destructors
    call rax

    ; Loop forever if we ever return:
fail2boot:
    hlt
    jmp fail2boot


extern mb2_info_first_tag, mb2_info_max_size
initialize_mb2:
    mov rsi, Multiboot2SaveRegs.ebx
    add rsi, KERNEL_VIRTUAL_BASE
    mov eax, dword [rsi]
    add rax, KERNEL_VIRTUAL_BASE

    mov ebx, dword [rax]  ; size of multiboot info

    add rax, 8
    mov rdi, mb2_info_first_tag
    mov dword [rdi], eax
    mov rdi, mb2_info_max_size
    mov dword [rdi], ebx

    ret


bits 32
section .text_early

;; This code sets up the GDT that we will use.
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

%define GDT_FLAG_CODE 0xa
%define GDT_FLAG_DATA 0x2

%define GDT_FLAG_USER (1<<4)
%define GDT_FLAG_SYSTEM 0

%define GDT_FLAG_DPL0 0
%define GDT_FLAG_DPL1 (1 << 5)
%define GDT_FLAG_DPL2 (2 << 5)
%define GDT_FLAG_DPL3 (3 << 5)

%define GDT_FLAG_PRESENT (1 << 7)

%define GDT_FLAG_32   (1 << 14)
%define GDT_FLAG_LONG (1 << 13)

%define GDT_FLAG_G_4k (1 << 15)

%define GDT_FLAGS_COMMON (GDT_FLAG_USER | GDT_FLAG_DPL0 | GDT_FLAG_PRESENT | GDT_FLAG_G_4k)
%define GDT_FLAGS_CODE_32 (GDT_FLAG_CODE | GDT_FLAGS_COMMON | GDT_FLAG_32)
%define GDT_FLAGS_DATA_32 (GDT_FLAG_DATA | GDT_FLAGS_COMMON | GDT_FLAG_32)
%define GDT_FLAGS_CODE_64 (GDT_FLAG_CODE | GDT_FLAGS_COMMON | GDT_FLAG_LONG)

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
    GDTENTRY GDT_FLAGS_CODE_32, 0, 0xfffff
DATA_SEG EQU $-GDT    ;; Defines the GDT offset for data (both)
    GDTENTRY GDT_FLAGS_DATA_32, 0, 0xfffff
CODE_SEG_64 EQU $-GDT
    GDTENTRY GDT_FLAGS_CODE_64, 0, 0xfffff
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
