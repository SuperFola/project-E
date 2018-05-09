bits 16
org 0

start:
    jmp main

%include "../std/stdio.h"
%include "../std/gdt_loader.inc"

data:
    message db 'Kernel loaded', 13, 10, 0

main:
    mov ax, cs
    mov ds, ax

    mov si, message
    call proj_e_print
    ; jump here
    jmp $

times 2048-($-$$) db 0
