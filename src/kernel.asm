bits 16

start:
    jmp main

%include "std/stdio.inc"
%include "std/video.inc"

data:
    msg_ker  db 'Kernel loaded',  13, 10, 0
    msg_info db 'Project E is developped by SuperFola', 13, 10, 0
    ret_line db 13, 10, 0

    buffer times 72 db 0
    flag_gdt_installed db 0

    shell_cursor       db 'kernel> ',     0
    shell_command_help db 'help',   0
    shell_action_help  db 'help reboot info test', 13, 10, 0
    shell_command_rbt  db 'reboot', 0
    shell_command_info db 'info',   0
    shell_command_test db 'test',   0

    shell_error_wrong_command db 'Unknown command', 13, 10, 0

main:
    mov ax, cs
    mov ds, ax

    ; kernel was loaded successfully !
    mov si, msg_ker
    call proj_e_print16
    
    ;call proj_e_init_vid_mem16
    ;jmp $

shell_begin:
    mov si, ret_line
    call proj_e_print16
    mov si, shell_cursor       ; print cursor
    call proj_e_print16

    ; ask for user input
    mov di, buffer                ; move buffer to destination output
    mov ch, 72                    ; character limit
    call proj_e_get_user_input16  ; wait for user input

    ; to be able to do the comparisons tests
    mov si, buffer

    ; checks if user typed help command
    mov di, shell_command_help
    call proj_e_compare_string16
    jc .command_help

    ; check if user typed reboot command
    mov di, shell_command_rbt
    call proj_e_compare_string16
    jc .command_rbt

    ; check if user typed info command
    mov di, shell_command_info
    call proj_e_compare_string16
    jc .command_info

    mov di, shell_command_test
    call proj_e_compare_string16
    jc .command_test

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

; command info (shell_command_info) selected
.command_info:
    mov si, msg_info
    call proj_e_print16
    jmp shell_begin

; command command_test
.command_test:
    mov ah, CREATE_COLOUR(CHAR_ATTR_CYAN, CHAR_ATTR_RED)  ; cyan on red background
    call proj_e_clear_screen16
    mov cx, 0x0000
    call proj_e_move_cursor16
    jmp shell_begin

; command reboot (shell_command_rbt) selected
; this specific subroutine must be placed at the very end to avoid rebooting for nothing
.command_rbt:
    call proj_e_reboot16


times 16384-($-$$) db 0
