%ifndef filesystem_asm
%define filesystem_asm

bits 16

; Macro to read file more easily
; INPUT  : AX (LBA number for sector), BX (linear address, where it will be loaded), CX (sectors count)
; OUTPUT : CF if an error happen while to find it, ES:BX (where it's loaded)
%macro load_file 3
    mov ax, %1
    mov bx, %2
    mov cx, %3
    call proj_e_read_file
%endmacro

; parameters
sectors_per_track dw  18
heads_per_track   dw   2
bytes_per_sector  dw 512
drive_number      dw   0
msg_error_reading_floppy db '[!] Error while reading floppy', 13, 10, 0
; variables
abs_sector        dw   0
abs_head          dw   0
abs_track         dw   0

; Routine to convert a LBA (Logical Block Addresing) to CHS (Cylinder/Head/Sector)
; INPUT  : AX (LBA addr), sectors_per_track, heads_per_track
; OUTPUT : abs_sector (CHS sector addr), abs_head (CHS head addr), abs_track (CHS track addr)
proj_e_lbachs:
    xor dx, dx
    div word [sectors_per_track]
    inc dl
    mov byte [abs_sector], dl

    xor dx, dx
    div word [heads_per_track]
    mov byte [abs_head], dl
    mov byte [abs_track], al

    ret

; Routine to read files into memory more easily
; INPUT  : AX (LBA number for sector), BX (linear address, where it will be loaded), CX (sectors count)
; OUTPUT : CF if an error happen while to find it, ES:BX (where it's loaded)
proj_e_read_file:
    push ax
.reset_floppy:
    ; reset floppy
    xor ax, ax
    int 0x13
    ; retry if carry was set
    jc .reset_floppy
    ; LBA number for sector (count starts from 1)
    pop ax
    add ax, 1
    ; save size
    push cx
    ; save destination
    push bx
.floppy:
    ; convert LBS to CHS
    call proj_e_lbachs

    ; set where it will be loaded
    pop bx
    mov es, bx
    xor bx, bx

    ; read floppy
    mov ah, 0x02
    mov al, 0x01                 ; number of blocks to read
    mov ch, byte [abs_track]     ; track (cylinder)
    mov cl, byte [abs_sector]    ; sector count stars from 1
    mov dh, byte [abs_head]      ; head
    mov dl, byte [drive_number]  ; drive number
    int 0x13

    push bx
    jnc .sectordone
    ; if we are here, we got an error while reading
    jmp .error
.sectordone:
    ; move where we are writing currently (avoid overwriting)
    pop bx
    add bx, word [bytes_per_sector]
    push bx
    ; move the LBA
    inc ax
    ; retrieve size
    pop cx
    sub cx, 1
    cmp cx, 0x00
    jz .quit       ; if it is the end we don't want to save the counter again on
                   ; the stack. otherwise, we just push it again and jmp to .floppy
    push cx
    jmp .floppy
.error:
    ; set carry flag
    stc
    ; optionnal but well it's handy
    print msg_error_reading_floppy
    ; cleaning up things
    pop cx
    jmp .end
.quit:
    ; if we "quit" it means there were no errors, so clear the carry flag
    clc
.end:
    pop bx
    ret

%endif
