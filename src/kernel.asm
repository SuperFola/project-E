bits 16

start:
    jmp main

%include "std/stdio.asm"
%include "std/string.asm"
%include "std/video.asm"

data:
    msg_ker  db '[Kernel] Loaded',  13, 10, 0
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

    APP_BLOCK_START equ      5
    APP_BLOCKS_SIZE equ      8  ; 8*512B=4096B
    APP_SEGMENT     equ 0x7e00

main:
    mov ax, cs
    mov ds, ax

    ; kernel was loaded successfully !
    mov si, msg_ker
    call proj_e_print16

shell_begin:
    mov si, ret_line
    call proj_e_print16
    mov si, shell_cursor          ; print cursor
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
    mov cx, 0x0000                 ; set cursor position : x=0,y=0
    call proj_e_move_cursor16

    ; prepare to load app
    mov ah, 2                        ; sectors to read
    mov al, APP_BLOCKS_SIZE          ; number of blocks to read
    push word APP_SEGMENT            ; where it will be loaded
    pop es
    xor bx, bx                       ; reset bx to 0
    mov cx, APP_BLOCK_START + 1      ; sector count start from 1
    mov dx, 0
    int 0x13                         ; call interrupt
                                     ; Writes error to Carry flag
    jnc .jump_to_app                 ; loading success, no error in carry flag

.app_loading_error:
    mov si, msg_app_load_err
    call proj_e_print16
    jmp shell_begin

.jump_to_app:
    mov si, msg_app_load_ok
    call proj_e_print16
    jmp APP_SEGMENT
    ; jump back when exiting app
    jmp shell_begin

; command reboot (shell_command_rbt) selected
; this specific subroutine must be placed at the very end to avoid rebooting for nothing
.command_rbt:
    call proj_e_reboot16

; 16kB kernel
times 16384-($-$$) db 0
