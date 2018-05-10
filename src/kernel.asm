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
    shell_action_help  db 'help reboot info', 13, 10, 0
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

    ; check if user typed reboot command
    mov di, shell_command_rbt
    call proj_e_compare_string
    jc .command_rbt

    ; check if user typed info command
    mov di, shell_command_info
    call proj_e_compare_string
    jc .command_info

    mov di, shell_command_test
    call proj_e_compare_string
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

; command reboot (shell_command_rbt) selected
.command_rbt:
    call proj_e_reboot16

; command info (shell_command_info) selected
.command_info:
    mov si, msg_info
    call proj_e_print16
    jmp shell_begin

; command command_test
.command_test:
    call proj_e_init_vid_mem
    jmp shell_begin


times 2048-($-$$) db 0
