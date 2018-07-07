bits 16

start:
    jmp main

%include "std/readdisk.asm"
%include "std/writedisk.asm"
%include "std/video.asm"
%include "std/string.asm"
%include "std/stdio.asm"
%include "std/macros.asm"

data:
    ; our stack and the current pointer
    memory times 256 db 0
    ptr              db 0
    ; the code and the index of the current instruction
    code   times 256 db 0
    index            db 0
    ; shell related
    cursor db 'plum> ', 0

main:
    ; set segments
    mov ax, cs
    mov ds, ax

shell_begin:
    print cursor
    ; ask for user input
    input buffer, 256

    ;mov si, s
    ;call proj_e_2hex_to_int
    ;call proj_e_print_hex

end:
    jmp KERNEL_LOAD_ADDRESS:0x0000

; 16 kB application
times 16384-($-$$) db 0
