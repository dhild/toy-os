global memcpy:function, strlen:function, strcpy:function
global inb:function, outb:function

; void* memcpy ( void* dest in rdi, const void * src in rsi, qword num in rdx )
memcpy:
    push rcx ; used for the count
    push rdi ; store for return value

    mov rcx, rdx
    rep movsb ; mov byte [rsi], byte[rdi]; rcx times

    pop rax ; return dest
    pop rcx

    ret



;qword strlen( const char* s in rdi );
strlen:
    push rsi

    mov rsi, rdi

    xor al, al

    repne scasb

    sub rdi, rsi
    mov rax, rdi

    pop rsi

    ret
    


;char* strcpy( char* dest in rdi, const char* src in rsi );
strcpy:
    push rdi ; save for return

.loop:
    mov al, byte [rsi]
    cmp al, 0
    je .done
    mov byte [rdi], al
    inc rsi
    inc rdi
    jmp .loop

.done:
    pop rax ; return char* dest

    ret


;byte inb( const byte port in rdi );
inb:
    push rdx

    mov dx, di
    xor rax, rax

    in al, dx

    pop rdx

    ret

;void outb( const byte output in rdi, const byte port in rsi );
outb:
    mov dx, si
    mov ax, di

    out dx, al

    ret

