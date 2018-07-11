bits 16

start:
    jmp main

%include "std/defines.asm"
%include "std/readdisk.asm"
%include "std/writedisk.asm"
%include "std/video.asm"
%include "std/string.asm"
%include "std/stdio.asm"
%include "std/macros.asm"

data:
    ; our stack and the current pointer
    memory times 256 db 0
    mem_idx          db 0
    ; the code and the index of the current instruction
    buffer times 256 db 0
    buffer_index     db 0
    ; to store 2 digits hex numbers
    hexnum times 3   db 0
    ; shell related
    cursor db 'plum> ', 0
    cmd_help db 'help', 0
    cmd_exit db 'exit', 0
    cmd_list db 'Commands: help exit', 13, 10, 0
    help_str db 'Language description', 13, 10
             db '====================', 13, 10
             db '! (print mem[p] until \0)', 13, 10
             db '? (read line, max:256)', 13, 10
             db 'b[x] (p -= x) ; B (p--)', 13, 10
             db 'f[x] (p += x) ; F (p++)', 13, 10
             db 's[x] (mem[p] = x) ; S[...] (while code[i]!=$: mem[p++]=x)', 13, 10
             db 'i[x] (if mem[p] != 0, code index=x (absolute))', 13, 10
             db 'P (prints the value of the memory pointer)', 13, 10
             db 13, 10
             db 'operators: + - / * %', 13, 10
             db 'x: 2 hex digits [0-9a-fA-F]', 13, 10
             db 0
    ; messages
    msg_parsing_err db 'Could not interpret token at 0x', 0
    msg_memptr_mov_error db 'Could not move memory pointer: invalid destination', 13, 10, 0

main:
    ; set segments
    mov ax, cs
    mov ds, ax
    cld

shell_begin:
    print cursor
    ; ask for user input
    input buffer, 255
    mov si, buffer

    ; check for commands before intepreting
    mov di, cmd_help
    call proj_e_compare_string
    jc .command_help

    mov di, cmd_exit
    call proj_e_compare_string
    jc .command_exit

    mov si, buffer
    jmp interpreter

    .command_help:
        print cmd_list
        print nl
        print help_str
        print nl
        jmp shell_begin

    .command_exit:
        jmp end

interpreter:
    .main:
        ; if it is the end of the string, go back to the shell
        cmp byte [si], 0
        je shell_begin
        ; else, read a character and execute instruction
        ; '!': 33, '%': 37, '*': 42, '+': 43, '-': 45, '/': 47, '?': 63, 'B': 66
        ; 'F': 70, 'P': 80, 'S': 83, 'b': 98, 'f': 102, 'i': 105, 's': 115
        cmp byte [si], 33  ; if byte <> '!'
        jl .error          ; lower => error
        je .print          ; equal => ok
        ; greater =>
        cmp byte [si], 37  ; if byte <> '%'
        jl .error
        je .modulo
        ; greater =>
        cmp byte [si], 42  ; if byte <> '*'
        jl .error
        je .multiply
        ; greater =>
        cmp byte [si], 43  ; if byte <> '+' (can not be lower if we're here)
        je .addition
        ; greater =>
        cmp byte [si], 45  ; if byte <> '-'
        jl .error
        je .substract
        ; greater =>
        cmp byte [si], 47  ; if byte <> '/'
        jl .error
        je .divide
        ; greater =>
        cmp byte [si], 63  ; if byte <> '?'
        jl .error
        je .readline
        ; greater =>
        cmp byte [si], 66  ; if byte <> 'B'
        jl .error
        je .backward
        ; greater =>
        cmp byte [si], 70  ; if byte <> 'F'
        jl .error
        je .forward
        ; greater =>
        cmp byte [si], 80  ; if byte <> 'P'
        jl .error
        je .print_ptr
        ; greater =>
        cmp byte [si], 83  ; if byte <> 'S'
        jl .error
        je .store
        ; greater =>
        cmp byte [si], 98  ; if byte <> 'b'
        jl .error
        je .backward_args
        ; greater =>
        cmp byte [si], 102  ; if byte <> 'f'
        jl .error
        je .forward_args
        ; greater =>
        cmp byte [si], 105  ; if byte <> 'i'
        jl .error
        je .if
        ; greater =>
        cmp byte [si], 115  ; if byte <> 's'
        jl .error
        je .store_one
        jg .error

    .print:
        push si
        mov si, memory
            xor ch, ch
            mov cl, byte [mem_idx]
            add si, cx
        mov ah, 0x0e     ; specify int 0x10 (teletype output)
        .printchar:
            lodsb            ; load byte from si into al, increment si
            cmp al, 0        ; is it the end of the string ?
            je .print_done   ; yes => quit ; no => continue
            int 0x10         ; print the character
            jmp .printchar
        .print_done:
            print nl
            pop si
            jmp .next

    .modulo:
        jmp .next

    .multiply:
        jmp .next

    .addition:
        jmp .next

    .substract:
        jmp .next

    .divide:
        jmp .next

    .readline:
        jmp .next

    .backward:
        cmp byte [mem_idx], 0x00
        je .backward_error
        dec byte [mem_idx]
        jmp .next

        .backward_error:
            print msg_memptr_mov_error
            jmp shell_begin

    .forward:
        cmp byte [mem_idx], 0xff
        je .forward_error
        inc byte [mem_idx]
        jmp .next

        .forward_error:
            print msg_memptr_mov_error
            jmp shell_begin

    .print_ptr:
        xor ah, ah
        mov byte al, byte [mem_idx]
        call proj_e_print_hex
        push si
            print nl
        pop si
        jmp .next

    .store:
        mov di, memory
            ; moving the cursor
            xor ch, ch
            mov cl, [mem_idx]
            add di, cx  ; move to current memory
        call .move_in_buffer
            mov byte al, [si]
            cmp byte al, '$'  ; if character is '$', it is the end
            je .next
            mystosb di  ; storing character as-is in memory
                ; going forward in the memory
                cmp byte [mem_idx], 0xff
                je .forward_error  ; if we can't, throw an error
                inc byte [mem_idx]
                jmp .store

    .backward_args:
        call .readhexval
            ; checking if we can substract ax from cx
            xor ch, ch
            mov cl, byte [mem_idx]
            cmp cx, ax
            jl .backward_error
        sub byte [mem_idx], byte al
        jmp .next

    .forward_args:
        call .readhexval
            ; checking if we can add ax to cx
            xor ch, ch
            mov cl, 0xff
            sub cl, byte [mem_idx]
            cmp cx, ax
            jl .forward_error
        add byte [mem_idx], byte al
        jmp .next

    .if:
        push si
        mov si, memory
            ; move in the memory to compare the current memory thing
            xor ch, ch
            mov cl, byte [mem_idx]
            add si, cx
        cmp byte [si], 0x00
        je .equal
        pop si
        jmp .next

        .equal:
            pop si
            call .readhexval
            ; reset buffer current character pointed
            mov si, buffer
            mov byte [buffer_index], 0x00
            ; set up counter
            mov cx, ax
            .loop:
                call .move_in_buffer
                dec cx
                cmp cx, 0x00
                jne .loop
            jmp interpreter

    .store_one:
        call .readhexval

        mov di, memory
            ; moving the cursor
            xor ch, ch
            mov cl, [mem_idx]
            add di, cx  ; move to current memory
        mystosb di      ; store ax in di
        inc byte [mem_idx]  ; move memory pointer

        jmp .next

    .error:
        print msg_parsing_err
            ; print the offset of the unknown character in the last buffer
            xor ah, ah
            printhex [buffer_index]
        print nl
        jmp shell_begin

    .next:
        call .move_in_buffer
        jmp interpreter

    .move_in_buffer:
        inc si
        inc byte [buffer_index]
        ret

    .readhexval:
        ; number will be in AL
        push di
            ; going to copy the hexnumber to a temporary buffer
            mov di, hexnum
            xor ah, ah

            ; going foward in the buffer to fetch a character
            call .move_in_buffer
            mov byte al, [si]
            mov [di], byte al

            ; going forward in our temporary buffer
            inc di
            ; going forward in the buffer to fetch the next character
            call .move_in_buffer
            mov byte al, [si]
            mov [di], byte al
            ; going back on the first character of the string in the temporary buffer
            dec di

            push si
                ; copying di to si to transform the string to a number
                mov si, di
                call proj_e_2hex_to_int
            pop si
        pop di

        ret

end:
    jmp KERNEL_LOAD_ADDRESS:0x0000

; 16 kB application
times 16384-($-$$) db 0
