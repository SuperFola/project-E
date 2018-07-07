%ifndef proj_e_readdisk_asm
%define proj_e_readdisk_asm

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

%include "std/disk.asm"
%include "std/macros.asm"

; Routine to read files into memory more easily
; INPUT  : AX (LBA number for sector), BX (linear address, where it will be loaded), CX (sectors count)
; OUTPUT : CF if an error happen while to find it, ES:BX (where it's loaded)
proj_e_read_file:
.begin:
    ; save destination
    mov word [destination], bx
    ; save LBA
    mov word [lba_number], ax
.main:
    mov di, 0x0005  ; retry count
.loop:
    ; get track, sector, and head
    mov ax, word [lba_number]
    call proj_e_lbachs

    ; move forward to avoid overwriting
    push word [destination]
    pop es
    xor bx, bx

    ; save counter (for loop)
    push cx

    ; read floppy
    mov ah, 0x02
    mov al, 0x01
    mov ch, byte [abs_track]
    mov cl, byte [abs_sector]
    mov dh, byte [abs_head]
    mov dl, byte [drive_number]
    int 0x13

    ; restore counter
    pop cx

    ; if no error, go to next sector
    jnc .sectordone

    ; otherwise reset disk
    xor ax, ax
    int 0x13
    ; decrement number of trials left
    dec di

    ; retry
    jnz .loop
    ; we got an error, impossible to read.
    jmp .error
.sectordone:
    ; move forward
    add word [destination], 0x20
    ; increment LBA
    inc word [lba_number]
    ; decrement ecx, go to label while non-zero
    loop .main
    jmp .quit
.error:
    ; set carry flag
    stc
    ; optionnal but well it's handy
    print msg_error_reading_floppy
    ; cleaning up things
    jmp .end
.quit:
    ; if we "quit" it means there were no errors, so clear the carry flag
    clc
.end:
    ret

%endif
