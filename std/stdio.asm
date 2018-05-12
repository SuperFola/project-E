%ifndef stdio_asm
%define stdio_asm

bits 16

%macro mystosb16_di 0
    mov [di], al
    inc di
%endmacro

%macro print 1
    mov si, %1
    call proj_e_print16
%endmacro

; Routine for outputting a string on the screen
; INPUT  : SI (containing address of the string)
; OUTPUT : none
proj_e_print16:
    mov ah, 0x0e     ; specify int 0x10 (teletype output)
.printchar:
    lodsb            ; load byte from si into al, increment si
    cmp al, 0        ; is it the end of the string ?
    je .done         ; yes => quit ; no => continue
    int 0x10         ; print the character
    jmp .printchar
.done:
    ret

; Routine to reboot the machine
; INPUT  : none
; OUTPUT : none
proj_e_reboot16:
    db 0x0ea         ; sending us to the end of the memory, to reboot
    dw 0x0000
    dw 0xffff

; Routine to wait for any key press
; INPUT  : none
; OUTPUT : none
proj_e_waitkeypress16:
    mov ah, 0
    int 0x16         ; BIOS keyboard service
    ret

%endif
