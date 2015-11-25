global setup_paging:function
global fixup_paging:function
extern kernel_physical_start, kernel_start, kernel_size
extern stack_physical_start, kernel_virtual_offset
bits 32
section .text_early

%define PTE_SHIFT   12
%define PDE_SHIFT   21
%define PDPE_SHIFT  30
%define PML4E_SHIFT 39

%define PAGE_SIZE   (1 << 12)
%define PAGE_MASK   (PAGE_SIZE - 1)

%define PTE(x)      (((x) >> PTE_SHIFT) & 0x1ff)
%define PDE(x)      (((x) >> PDE_SHIFT) & 0x1ff)
%define PDPE(x)     (((x) >> PDPE_SHIFT) & 0x1ff)
%define PML4E(x)    (((x) >> PML4E_SHIFT) & 0x1ff)

%define PF_PRESENT       1
%define PF_RW            (1 << 1)
%define PF_USER          (1 << 2)
%define PF_WRITETHRU     (1 << 3)
%define PF_DISABLE_CACHE (1 << 4)


setup_paging:

    ;; First we must zero out the page data structures.
    ;; Count out how many:

    ; eax = size of kernel, rounded up to the next page
    mov eax, kernel_size
    add eax, PAGE_MASK
    and eax, -PAGE_SIZE

    ; ebx = end of kernel pages
    mov ebx, eax
    add ebx, kernel_physical_start

    ;; ecx = pte index of first kernel page
    mov ecx, kernel_physical_start
    shr ecx, PTE_SHIFT
    and ecx, 0x1ff

    ;; edx = Number of page structures required.
    ;; Starts out at 4 to count at least one PT, PD, PDP, and PML4
    mov edx, 4

    ;; Count the pages in the kernel
.count_early_pages:
    sub eax, PAGE_SIZE

    cmp ecx, 512        ; 512th PTE is the PTE of a new page table.
    jne .no_new_pt

    add edx, 1
    mov ecx, 0
    jmp .end

.no_new_pt:
    add ecx, 1

.end:
    cmp eax, 0
    jne .count_early_pages


    ;; Now set up counts for the actual zeroing

    ; ecx = end of kernel paging addresses
    mov ecx, edx
    shl ecx, PTE_SHIFT
    add ecx, ebx
    add ecx, PAGE_SIZE


    mov eax, ebx
.zero_page:
    mov dword [eax], 0
    add eax, 4
    cmp eax, ecx
    jne .zero_page


    ;; Now there are edx pages of zeroed memory for page tables,
    ;; starting at [ebx]

    ;; Make sure we have a PML4 pointing back at the physical address
    ;; of the PML4. We put it at PML4[510], second to last:
    ; eax = address of PML4[510]
    mov eax, ebx
    add eax, (8 * 510)

    ; edx = PML4 address + flags
    mov edx, ebx
    or edx, (PF_RW | PF_PRESENT)

    mov dword [eax], edx

    ;;
    ;; This will be set up as such:
    ;; ----- end of kernel [ebx]
    ;;   1  4k page PML4
    ;; -----
    ;;   1  4k page PDP
    ;; -----
    ;;   1  4k page PD
    ;; -----
    ;;   n  4k page PTs
    ;; ----- end of page structures [ecx]
    ;;
    ;; The initial map contains the identity map
    ;;     kernel_physical_start -> kernel_physical_start
    ;; as well as the higher memory mapping
    ;;     kernel_start -> kernel_physical_start
    ;;
    ;; We need two addresses:
    ;;
    ;; kernel_physical_start (0x100000)
    ;; PML4E 0
    ;; PDPE  0
    ;; PDE   0
    ;; PTE   256
    ;; This only lasts long enough to load the virtual version:
    ;;
    ;; kernel_start (0xffffffff80100000)
    ;; PML4E 511
    ;; PDPE  510
    ;; PDE   0
    ;; PTE   256
    
    ;; physical mapping PML4E:
    mov eax, ebx        ; PML4E[0]

    mov edx, ebx
    add edx, PAGE_SIZE
    or edx, (PF_RW | PF_PRESENT)

    mov dword [eax], edx

    ;; virtual mapping PML4E:
    mov eax, ebx
    add eax, 8 * 511    ; PML4E[511]

    mov dword [eax], edx


    ;; physical mapping PDP
    mov eax, ebx
    add eax, PAGE_SIZE  ; PDP[0]

    mov edx, ebx
    add edx, 2 * PAGE_SIZE
    or edx, (PF_RW | PF_PRESENT)

    mov dword [eax], edx

    ;; virtual mapping PDP
    mov eax, 0x80100000
    sar eax, PDPE_SHIFT
    and eax, 0x1ff
    shl eax, 3
    add eax, PAGE_SIZE
    add eax, ebx        ; PDP[510]

    mov dword [eax], edx

    ;; Technically, we've just mapped 4 PDPs (two in high, two in low)
    ;; We'll remove the low mappings later...

    ;; PD gets interesting, we don't know the count for sure at compile time
    ;; We're using the same PDs for physical & virtual, however.
    mov eax, kernel_physical_start
    sar eax, PDE_SHIFT
    and eax, 0x1ff
    shl eax, 3
    add eax, (2 * PAGE_SIZE)
    add eax, ebx

    mov edx, ebx
    add edx, (3 * PAGE_SIZE)

    ;; ecx = end of paging structures
.write_pde:
    mov esi, edx
    or esi, (PF_RW | PF_PRESENT)

    mov dword [eax], esi

    add eax, 8
    add edx, PAGE_SIZE
    cmp edx, ecx
    jne .write_pde


    ;; Set up some pages for the stack.
    ;;
    ;; Physically, these are in the kernel data, and virtually,
    ;; they occupy 4 pages below 0x100000, so we don't overflow
    ;; and overwrite the kernel.

    mov eax, kernel_physical_start
    sub eax, 4 * PAGE_SIZE
    sar eax, PTE_SHIFT
    and eax, 0x1ff
    shl eax, 3
    add eax, ebx
    add eax, (3 * PAGE_SIZE)    ; PTE[252]

    mov edx, stack_physical_start
    or edx, (PF_RW | PF_PRESENT)

    mov ecx, 4
.write_stack_pte:
    mov dword [eax], edx
    add eax, 8
    add edx, PAGE_SIZE
    dec ecx
    jnz .write_stack_pte


    ;; Now write the remaing PTEs. We're already where we need to be
    ;; for these in the PTE index [eax].
    ;; Interesting note: the kernel stack is visible in here too.

    mov edx, kernel_physical_start

.write_kernel_pte:
    mov esi, edx
    or esi, (PF_RW | PF_PRESENT)

    mov dword [eax], esi

    add eax, 8
    add edx, PAGE_SIZE
    cmp edx, ebx
    jne .write_kernel_pte

    ;; All done setting up paging data!

    ret

bits 64
fixup_paging:
    ;; Using the self-mapped addresses of the PML4,
    ;; remove the PDP[0] and PML4[0] that were used
    ;; to cheat into a physical 1-1 map.

    ; Zero PDP[0] first
    ; PML4E[510] PDPE[510] PDTE[510] PTE[0] -> paging_base + PAGE_SIZE = PDP[0]
    mov rax, 0xffffff7fbfc00000
    mov dword [rax], 0

    ; Now zero PML4[0]
    ; PML4E[510] PDPE[510] PDTE[510] PTE[510] -> paging_base = PML4[0]
    mov rax, 0xffffff7fbfdfe000
    mov dword [rax], 0

    ; reset cr3 to update
    mov rax, cr3
    mov cr3, rax

    ret

