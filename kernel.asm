bits 16

start:
    jmp main

%include "std/stdio.inc"
;%include "std/gdt_loader.inc"
;%include "std/A20.inc"

;data:
    msg_ker db 'Kernel loaded',  13, 10, 0
    ;msg_gdt db 'GDT installed',  13, 10, 0
    ;msg_a20 db 'A20 enabled',    13, 10, 0
    ;msg_32B db 'Entering pmode', 13, 10, 0

    shell_cursor db '~$ ', 0
    buffer times 128 db 0
    shell_command_help db 'help', 0
    shell_action_help db 'Type help to get help', 13, 10, 0
    shell_error_wrong_command db 'Wrong input', 13, 10, 0

main:
    mov ax, cs
    mov ds, ax

    ; kernel was loaded successfully !
    mov si, msg_ker
    call proj_e_print16

shell_begin:
  mov si, shell_cursor   ; print > cursor
  call proj_e_print16

  mov di, buffer         ; move buffer to destination output
  call proj_e_get_user_input ; wait for user input

  mov si, buffer         ; copy user input to SI

  mov di, shell_command_help
  call proj_e_compare_string ; checks if user typed help command
  jc .command_help

  ; wrong user input (command not recognized)
  .wrong_input_error:
    mov si, shell_error_wrong_command
    call proj_e_print16
    jmp shell_begin

  ; command help (shell_command_help) selected
  .command_help:
    mov si, shell_action_help
    call proj_e_print16
    jmp shell_begin      ; reset shell

    ; loading the Global Descriptor Table
    ;call proj_e_installGDT16
    ;mov si, msg_gdt
    ;call proj_e_print16

    ; enable A20
    ;call EnableA20_KKbrd_Out
    ;mov si, msg_a20
    ;call proj_e_print16

    ;mov si, msg_32B
    ;call proj_e_print16

    ; starting the protected mode configuration
    ;cli
    ;mov eax, cr0  ; set bit0 : enter pmode
    ;or eax, 1
    ;mov cr0, eax

    ;jmp CODE_DESC:kernel32 ; doing a far jump to fix CS
    ; from now, do not re-enable interrupts !!
    ; it would cause triple fault :c

    ; jump here
    jmp $

; ***********************
;        Kernel 32
; ***********************

;bits 32

;kernel32:
;    mov ax, DATA_DESC
;    mov ds, ax
;    mov ss, ax
;    mov es, ax
;    mov esp, 0x90000

;stop:
;    cli
;    hlt

times 2048-($-$$) db 0
