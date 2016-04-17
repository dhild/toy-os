global _start:function  	; making entry point visible to linker
global cleanup_32:function
extern GDTR, GDT, CODE_SEG_32, DATA_SEG, CODE_SEG_64
extern setup_idt, setup_paging
extern fixup_gdtr, fixup_idtr, fixup_paging
extern kernel_start, kernel_physical_start, kernel_physical_end
extern header_signature_addr, stack_physical_end
extern kernel_main
bits 32

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
    dd _start
    dd 0        ; Graphics mode
    dd 1024     ; width
    dd 768      ; height
    dd 32       ; depth


%define MULTIBOOT2_HEADER_MAGIC         0xe85250d6
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
TagEnd:
    dw MULTIBOOT_TAG_TYPE_END
    dw 0
    dd (.end - TagEnd)
.end:

align MULTIBOOT_TAG_ALIGN
Multiboot2HeaderEnd:


section .text_early

;; Structure to preserve Multiboot flags:
MultibootState:
    dd 0 ; EAX
    dd 0 ; EBX

_start:
setupLongMode:
    ;; Keep interrupts disabled until we are set to handle them.
    cli

    mov ebp, MultibootState
    mov dword [ebp], eax
    mov dword [ebp + 4], ebx

    lgdt [GDTR]

    mov eax, DATA_SEG
    mov ds, eax
    mov es, eax
    mov fs, eax
    mov gs, eax
    mov ss, eax

    mov esp, stack_physical_end
    sub esp, 8
    mov ebp, esp
    
    ;; Reload the code segment
    jmp CODE_SEG_32:hosted_gdt

hosted_gdt:

    call setup_idt

    ; Initialize paging. PML4 address is in ebx after return
    call setup_paging

    ;; Set up for 64-bit mode
    ; 1. Disable paging, bit 31 of cr0
    mov eax, cr0
    and eax, 0x7FFFFFFF
    mov cr0, eax

    ; 2. Enable PAE, 6th bit of cr4
    mov eax, cr4
    or eax, 0010_0000b
    mov cr4, eax

    ; 3. Load cr3 with the physical address of the page table
    mov cr3, ebx

    ; 4. Enable IA-32e mode by setting IA32_EFER.LME = 1.
    mov ecx, 0xC0000080
    rdmsr
    or eax, (1 << 8)
    wrmsr

    ; 5. Enable paging, bit 31 of cr0
    mov eax, cr0
    or eax, (1 << 31)
    mov cr0, eax

    ;;  The change from compatibility to 64-bit mode, we need a fresh jump
    ;;  using a 64-bit GDT pointer
    jmp CODE_SEG_64:cleanup_32

cleanup_32:

bits 64
    ;; Jump into the loaded virtual 64-bit address

    mov rax, 0xffffffff80000000
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

    ; Call the kernel's main entry
    mov rax, kernel_main
    call rax

    ; Loop forever if we ever get here:
    jmp $

