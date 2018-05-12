%ifndef filesystem_asm
%define filesystem_asm

bits 16

; Macro to read file more easily
; INPUT  : size, addr_where_it_should_be_loaded, what_sector_is_it_in
; OUTPUT : CF if unable to find it
%macro load_file 3
.reset_floppy:
    ; reset floppy
    xor ax, ax
    int 0x13
    jc .reset_floppy   ; retry if carry was set
.floppy:
    ; set where it will be loaded
    mov ax, %2
    mov es, ax
    xor bx, bx
    ; read floppy
    mov ah, 0x02
    mov al, %1         ; number of blocks to read
    xor ch, ch         ; track (cylinder) 1
    mov cl, %3 + 1     ; sector count stars from 1
    xor dh, dh         ; head 1
    int 0x13
%endmacro

%endif
