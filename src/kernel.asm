bits 16
org 0
[map all kernel.map]

start:
    jmp main

%macro check_command 3
    mov di, %1
    call %2
    jc %3
    mov si, buffer
%endmacro

%include "std/stdio.asm"
%include "std/string.asm"
%include "std/video.asm"
%include "std/readdisk.asm"

data:
    version  db 'v0.2.2', 0
    msg_info db 'Project-E is a monolithic kernel working in 16-bits real mode', 13, 10
             db 'developped by SuperFola', 13, 10
             db 0
    msg_app_load_ok   db '[Kernel] App loaded into RAM @ 0x8000', 13, 10, 0
    msg_app_load_err  db '[!] [Kernel] Could not load app', 13, 10, 0
    msg_plum_load_ok  db '[Kernel] Plum loaded into RAM @ 0x9000', 13, 10, 0
    msg_plum_load_err db '[!] [Kernel] Could not load plum', 13, 10, 0
    msg_error_clear   db '[!] [Clear] Wrong argument', 13, 10, 0

    buffer times 72 db 0
    password        db 115, 99, 105, 112, 105, 111, 0

    ask_pass   db 'Password? ', 0
    wrong_pass db '[!] Wrong password', 13, 10, 0
    good_pass  db '[Info] Access granted', 13, 10, 0
    pwd_state  db 0

    pwd_lock times 72 db 0
    ask_lock          db 'Lock? ', 0

    cursor        db 'kernel> ', 0
    command_echo  db 'echo',    0
    command_clear db 'clear',   0
    command_help  db 'help',    0
    command_rbt   db 'reboot',  0
    command_info  db 'info',    0
    command_test  db 'test',    0
    command_plum  db 'plum',    0
    command_ver   db 'version', 0
    command_lock  db 'lock',    0
    action_help   db 'echo clear help reboot info test plum', 13, 10
                  db 'version lock', 13, 10
                  db 0

    msg_cmd_error db 'Unknown command', 13, 10, 0

    APP_BLOCK_START equ     33
    APP_BLOCKS_SIZE equ      8  ; 8*512B=4096B
    APP_SEGMENT     equ 0x07e0  ; 0x07e0:0x0000=0x7e00

    PLUM_BLOCK_START equ     41
    PLUM_BLOCKS_SIZE equ     32 ; 32*512B=16384B
    PLUM_SEGMENT     equ 0x0900 ; 0x0900:0x0000=0x9000

main:
    ; set up registers
    mov ax, cs
    mov ds, ax

    print nl

    ; retry counter for password
    mov cx, 3
    ; if has_laready_entered_pwd_and_correct
    cmp byte [pwd_state], 1
    ; go to shell
    je shell_begin
    ; otherwise, ask for it

.ask:
    push cx
    print ask_pass

    ; get password
    getpass buffer, 72
    mov si, buffer

    ; compare strings
    mov di, password
    call proj_e_compare_string
    jc .access_granted
    print wrong_pass
    print nl

    ; decrement retry counter, when equal to 0, infinite loop
    pop cx
    sub cx, 1
    cmp cx, 0
    jne .ask

    mov byte [pwd_state], 255
    cli
    hlt

.access_granted:
    mov byte [pwd_state], 1
    print good_pass
    print nl

shell_begin:
    ; just in case
    clc

    print cursor
    ; ask for user input
    input buffer, 72
    ; to be able to do the comparisons tests
    mov si, buffer

    ; clear XY
    check_command command_clear, proj_e_compare_start_string, .clear
    ; echo ...
    check_command command_echo, proj_e_compare_start_string, .echo
    ; help
    check_command command_help, proj_e_compare_string, .help
    ; reboot
    check_command command_rbt, proj_e_compare_string, .reboot
    ; info
    check_command command_info, proj_e_compare_string, .info
    ; test: load app
    check_command command_test, proj_e_compare_string, .test
    ; plum: load app
    check_command command_plum, proj_e_compare_string, .plum
    ; version
    check_command command_ver, proj_e_compare_string, .version
    ; lock
    check_command command_lock, proj_e_compare_string, .lock

    ; wrong user input (command not recognized)
    ; only print message if there was a command
    .wrong_input_error:
        ; if len(str) == 0:
        call proj_e_length_string
        cmp ax, 0
        ; then
        ; don't print message
        je shell_begin
        ; else:
        ; error, can not find command
        print msg_cmd_error
        jmp shell_begin

.echo:
    ; if str == "echo":
    mov si, buffer
    mov di, command_echo
    call proj_e_compare_string
    ; then
    ; print only a newline
    jc .nl_echo
    ; else:
    ; wipe "echo "
    call proj_e_tokenize_string
    mov si, di
    ; check arguments length
    call proj_e_length_string
    cmp ax, 0
    ; if no argument, print a newline
    je .nl_echo
    ; else, print arguments
    print si
    print nl
    jmp .end_echo

    .nl_echo:
        print nl

    .end_echo:
        jmp shell_begin

.clear:
    ; if len(cmd.split(' ')) != 2:
    call proj_e_tokenize_string
    mov si, di
    call proj_e_length_string
    cmp ax, 2
    ; then
    ; error()
    jne .error_clear
    ; else:
    ; try: convertToInteger(cmd.split(' ')[1])
    call proj_e_2hex_to_int
    ; except: error()
    jc .error_clear
    ; finally:
    mov ah, al                  ; parsed integer is in AL, not in AH
    ; clear screen
    call proj_e_clear_screen
    move_cursor 0x0000          ; move cursor in x=0,y=0
    jmp .end_clear

    .error_clear:
        print msg_error_clear

    .end_clear:
        jmp shell_begin

.help:
    print action_help
    jmp shell_begin

.reboot:
    call proj_e_reboot

.info:
    print msg_info
    jmp shell_begin

.test:
    mov ah, CREATE_COLOUR(CHAR_ATTR_CYAN, CHAR_ATTR_RED)  ; cyan on red background
    call proj_e_clear_screen
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

.plum:
    mov ah, CREATE_COLOUR(CHAR_ATTR_WHITE, CHAR_ATTR_BLACK)
    call proj_e_clear_screen
    ; move cursor in x=0, y=0
    move_cursor 0x0000

    ; prepare to load app
    load_file PLUM_BLOCK_START, PLUM_SEGMENT, PLUM_BLOCKS_SIZE
    jnc .jump_to_plum

    .plum_loading_error:
        print msg_plum_load_err
        jmp shell_begin

    .jump_to_plum:
        print msg_plum_load_ok
        jmp PLUM_SEGMENT:0x0000

.version:
    print version
    print nl
    jmp shell_begin

.lock:
    ; get password
    print ask_lock
    getpass pwd_lock, 72

    ; while (1)
    .loop_pwd:
        ; buffer=getpass("Password? ")
        print ask_pass
        getpass buffer, 72
        ; if buffer != ask_lock:
        mov si, buffer
        mov di, pwd_lock
        call proj_e_compare_string
        ; then
        ; loop again
        jnc .loop_pwd
        ; else:
        ; go to kernel
        jmp shell_begin

; 16kB kernel
times 16384-($-$$) db 0
