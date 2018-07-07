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
    memory_index     db 0
    ; the code and the index of the current instruction
    buffer times 256 db 0
    buffer_index     db 0
    ; shell related
    cursor db 'plum> ', 0
    cmd_help db 'help', 0
    cmd_exit db 'exit', 0
    cmd_list db 'help exit', 13, 10, 0
    help_str db '! (print mem[p] until \0)', 13, 10
             db '? (read line, max:256)', 13, 10
             db 'b[x] (p -= x) ; B (p--)', 13, 10
             db 'f[x] (p += x) ; F (p++)', 13, 10
             db 's[x] (mem[p] = x)', 13, 10
             db 'i[x] (if mem[p] != 0, code index=x)', 13, 10
             db 'operators: + - / * %', 13, 10
             db 'x: 2 hex digits (0-9, a-f)', 13, 10
             db 0

main:
    ; set segments
    mov ax, cs
    mov ds, ax

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
    jmp shell_begin

    ;mov si, s
    ;call proj_e_2hex_to_int
    ;call proj_e_print_hex

end:
    jmp KERNEL_LOAD_ADDRESS:0x0000

; 16 kB application
times 16384-($-$$) db 0
