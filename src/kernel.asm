bits 16
org 0

start:
    jmp main

%include "std/stdio.asm"
%include "std/string.asm"
%include "std/video.asm"
%include "std/filesystem.asm"

data:
    msg_info db 'Project E is developped by SuperFola', 13, 10, 0
    ret_line db 13, 10, 0
    msg_app_load_ok  db '[Kernel] App loaded', 13, 10, 0
    msg_app_load_err db '[!] [Kernel] Could not load app', 13, 10, 0

    buffer times 72 db 0
    flag_gdt_installed db 0

    shell_cursor       db 'kernel> ',     0
    shell_command_help db 'help',   0
    shell_action_help  db 'help reboot info test', 13, 10, 0
    shell_command_rbt  db 'reboot', 0
    shell_command_info db 'info',   0
    shell_command_test db 'test',   0

    shell_error_wrong_command db 'Unknown command', 13, 10, 0

    APP_BLOCK_START equ     33
    APP_BLOCKS_SIZE equ      8  ; 8*512B=4096B
    APP_SEGMENT     equ 0x07e0  ; 0x07e0:0x0000=0x8000

main:
    mov ax, cs
    mov ds, ax

shell_begin:
    print ret_line
    print shell_cursor            ; print cursor

    ; ask for user input
    input buffer, 72

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
    print shell_error_wrong_command
    jmp shell_begin

; command help (shell_command_help) selected
.command_help:
    print shell_action_help
    jmp shell_begin

; command reboot (shell_command_rbt) selected
; this specific subroutine must be placed at the very end to avoid rebooting for nothing
.command_rbt:
    call proj_e_reboot16

; command info (shell_command_info) selected
.command_info:
    print msg_info
    jmp shell_begin

; command command_test
.command_test:
    mov ah, CREATE_COLOUR(CHAR_ATTR_CYAN, CHAR_ATTR_RED)  ; cyan on red background
    call proj_e_clear_screen16
    ; move cursor in x=0,y=0
    move_cursor 0x0000

    ; prepare to load app
    load_file APP_BLOCK_START, APP_SEGMENT, APP_BLOCKS_SIZE
    jnc .jump_to_app                 ; loading success, no error in carry flag

.app_loading_error:
    print msg_app_load_err
    jmp shell_begin

.jump_to_app:
    print msg_app_load_ok
    jmp APP_SEGMENT:0x0000

; 16kB kernel
times 16384-($-$$) db 0
