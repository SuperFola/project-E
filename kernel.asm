bits 16
org 0

start:
    jmp main

%include "std/stdio.inc"
%include "std/gdt_loader.inc"

data:
    msg_ker db 'Kernel loaded', 13, 10, 0
    msg_gdt db 'GDT installed', 13, 10, 0

main:
    mov ax, cs
    mov ds, ax

    mov si, msg_ker
    call proj_e_print16

    call proj_e_installGDT16
    mov si, msg_gdt
    call proj_e_print16

    ; jump here
    jmp $

times 2048-($-$$) db 0
