global kernel_entry:function  	; making entry point visible to linker
extern GDTR, GDT, CODE_SEG_32, DATA_SEG, CODE_SEG_64
extern setup_idt, setup_paging
extern fixup_gdtr, fixup_idtr, fixup_paging
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

    ; Setup for C++ by running the global constructors:
    mov rax, run_global_constructors
    call rax

    ; Call the kernel's main entry
    xor rdi, rdi
    xor rsi, rsi
    mov rax, KERNEL_VIRTUAL_BASE
    add rax, Multiboot2SaveRegs.eax
    mov edi, dword [rax]
    add rax, 4
    mov esi, dword [rax]
    add rax, KERNEL_VIRTUAL_BASE
    mov rax, kernel_main
    call rax

    ; Teardown for C++ by running the global destructors:
    mov rax, run_global_destructors
    call rax

    ; Loop forever if we ever return:
fail2boot:
    hlt
    jmp fail2boot

