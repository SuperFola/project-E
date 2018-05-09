%ifndef stdio_h_1337
%define stdio_h_1337

bits 16

; routine for outputting 'si' register on the screen
proj_e_print16:
    mov ah, 0Eh      ; specify int 10h (teletype output)
.printchar:
    lodsb            ; load byte from si into al, increment si
    cmp al, 0        ; is it the end of the string ?
    je .done         ; yes => quit ; no => continue
    int 10h          ; print the character
    jmp .printchar
.done:
    ret

; routine to reboot the machine
proj_e_reboot16:
    db 0x0ea         ; sending us to the end of the memory, to reboot
    dw 0x0000
    dw 0xffff

; routine to get a key press
proj_e_getkeypress16:
    mov ah, 0
    int 16h          ; BIOS keyboard service
    ret

%endif
