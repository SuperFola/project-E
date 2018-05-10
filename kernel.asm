bits 16

start:
    jmp main

%include "std/stdio.inc"
%include "std/gdt_loader.inc"
%include "std/A20.inc"
; %include "std/stdio32.inc"

%define DATA16_RELOC(x) (x + 0x1000)

data:
    msg_ker  db 'Kernel loaded',  13, 10, 0
    msg_gdt  db 'GDT installed',  13, 10, 0
    msg_gdt_error db '[!] GDT already installed', 13, 10, 0
    msg_a20  db 'A20 enabled',    13, 10, 0
    msg_32B  db 'Entering pmode', 13, 10, 0
    msg_info db 'Project E is developped by SuperFola', 13, 10, 0
    ret_line db 13, 10, 0

    buffer times 72 db 0
    flag_gdt_installed db 0

    shell_cursor       db 'kernel> ',     0
    shell_command_help db 'help',   0
    shell_action_help  db 'lgdt a20 pmode reboot info', 13, 10, 0
    shell_command_lgdt db 'lgdt',   0
    shell_command_a20  db 'a20',    0
    shell_command_32B  db 'pmode',  0
    shell_command_rbt  db 'reboot', 0
    shell_command_info db 'info',   0

    shell_error_wrong_command db 'Unknown command', 13, 10, 0

main:
    mov ax, cs
    mov ds, ax

    ; kernel was loaded successfully !
    mov si, msg_ker
    call proj_e_print16

shell_begin:
    mov si, ret_line
    call proj_e_print16
    mov si, shell_cursor       ; print cursor
    call proj_e_print16

    ; ask for user input
    mov di, buffer             ; move buffer to destination output
    mov ch, 72                 ; character limit
    call proj_e_get_user_input ; wait for user input

    ; to be able to do the comparisons tests
    mov si, buffer

    ; checks if user typed help command
    mov di, shell_command_help
    call proj_e_compare_string
    jc .command_help

    ; check if user typed lgdt command
    mov di, shell_command_lgdt
    call proj_e_compare_string
    jc .command_lgdt

    ; check if user typed a20 command
    mov di, shell_command_a20
    call proj_e_compare_string
    jc .command_a20

    ; check if user typed pmode command
    mov di, shell_command_32B
    call proj_e_compare_string
    jc .command_32B

    ; check if user typed reboot command
    mov di, shell_command_rbt
    call proj_e_compare_string
    jc .command_rbt

    ; check if user typed info command
    mov di, shell_command_info
    call proj_e_compare_string
    jc .command_info

; wrong user input (command not recognized)
.wrong_input_error:
    mov si, shell_error_wrong_command
    call proj_e_print16
    jmp shell_begin

; command help (shell_command_help) selected
.command_help:
    mov si, shell_action_help
    call proj_e_print16
    jmp shell_begin

; command lgdt (shell_command_lgdt) selected
.command_lgdt:
    ; did we already load the GDT ?
    mov cl, 1
    cmp cl, byte [flag_gdt_installed]
    je .command_lgdt_error
    ; loading the Global Descriptor Table
    call proj_e_installGDT16
    mov si, msg_gdt
    call proj_e_print16
    mov byte [flag_gdt_installed], 1
    jmp shell_begin
.command_lgdt_error:
    mov si, msg_gdt_error
    call proj_e_print16
    jmp shell_begin

; command a20 (shell_command_a20) selected
.command_a20:
    ; enable A20
    call EnableA20_KKbrd_Out
    mov si, msg_a20
    call proj_e_print16
    jmp shell_begin

; command pmode (shell_command_32B) selected
.command_32B:
    mov si, msg_32B
    call proj_e_print16
    ; starting the protected mode configuration
    cli
    mov eax, cr0  ; set bit0 : enter pmode
    or eax, 1
    mov cr0, eax

    ; not working :c !
    jmp dword 0x08:DATA16_RELOC(kernel32) ; doing a far jump to fix CS
    ; from now, do not re-enable interrupts !!
    ; it would cause triple fault :c

; command reboot (shell_command_rbt) selected
.command_rbt:
    call proj_e_reboot16

; command info (command_info) selected
.command_info:
    mov si, msg_info
    call proj_e_print16
    jmp shell_begin

; ***********************
;        Kernel 32
; ***********************

bits 32

kernel32:
    mov ax, DATA_DESC
    mov ds, ax
    mov ss, ax
    mov es, ax

    mov ebp, STACK_SEG32
    mov esp, ebp

stop:
    ; cli
    ; hlt
    jmp $

times 2048-($-$$) db 0
