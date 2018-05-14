%ifndef proj_e_stdio_asm
%define proj_e_stdio_asm

bits 16

%include "std/macros.asm"

nl db 13, 10, 0

; Routine for outputting a string on the screen
; INPUT  : SI (containing address of the string)
; OUTPUT : none
proj_e_print:
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
proj_e_reboot:
    db 0x0ea         ; sending us to the end of the memory, to reboot
    dw 0x0000
    dw 0xffff

; Routine to wait for any key press
; INPUT  : none
; OUTPUT : none
proj_e_waitkeypress:
    mov ah, 0
    int 0x16         ; BIOS keyboard service
    ret

; Routine to print an hexadecimal word to screen
; INPUT  : AX (number)
; OUTPUT : none
proj_e_print_hex:
    push ax
    call proj_e_print_hex_word
    ; cleanup stack after call
    add sp, 2
    ret

; Routine to print an hexadecimal word to screen
; INPUT  : number on the stack
; OUTPUT : none
proj_e_print_hex_word:
    push bp
    mov bp, sp      ; BP=SP, on 8086 can't use sp in memory operand
    push dx         ; Save all registers we clobber
    push cx
    push bx
    push ax

    mov cx, 0x0404  ; CH = number of nibbles to process = 4 (4*4=16 bits)
                    ; CL = Number of bits to rotate each iteration = 4 (a nibble)
    mov dx, [bp+4]  ; DX = word parameter on stack at [bp+4] to print
    mov bx, [bp+6]  ; BX = page / foreground attr is at [bp+6]

.loop:
    rol dx, cl      ; Roll 4 bits left. Lower nibble is value to print
    mov ax, 0x0e0f  ; AH=0E (BIOS tty print),AL=mask to get lower nibble
    and al, dl      ; AL=copy of lower nibble
    add al, 0x90    ; Work as if we are packed BCD
    daa             ; Decimal adjust after add.
                    ;    If nibble in AL was between 0 and 9, then CF=0 and
                    ;    AL=0x90 to 0x99
                    ;    If nibble in AL was between A and F, then CF=1 and
                    ;    AL=0x00 to 0x05
    adc al, 0x40    ; AL=0xD0 to 0xD9
                    ; or AL=0x41 to 0x46
    daa             ; AL=0x30 to 0x39 (ASCII '0' to '9')
                    ; or AL=0x41 to 0x46 (ASCII 'A' to 'F')
    int 0x10        ; Print ASCII character in AL
    dec ch
    jnz .loop       ; Go back if more nibbles to process

    pop ax          ; Restore registers
    pop bx
    pop cx
    pop dx
    pop bp
    ret

%endif
