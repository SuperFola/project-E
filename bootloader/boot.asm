bits 16

start:
    jmp main

%include "../std/stdio.inc"

main:
    cli              ; move registers for offset of BIOS 07C0h load point
    mov ax, 07C0h    ; offset
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ax, 0x0000   ; init the stack
    mov ss, ax
    mov sp, 0xffff
    sti

    mov si, message
    call proj_e_print16
    call proj_e_getkeypress16

    mov ax, 0x01       ; LBA number 1 for sector
    mov cx, 0x02       ; read two sectors from the floppy disk
    mov bx, 0x200
    ; call the read sectors function
    call proj_e_readsectors

    ; address ES offset BX returned from read sectors (call kernel)
    jmp 0x7e0:0

data:
    ; strings
    message    db 'Hello World! Press any key to load the kernel', 13, 10, 0
    ; parameters
    sectors_per_track  dw  18
    heads_per_track    dw   2
    bytes_per_sector   dw 512
    drive_number       dw   0
    ; variables
    abs_sector dw 0x00
    abs_head   dw 0x00
    abs_track  dw 0x00

; LBA to CHS
; input  : AX (LBA addr), sectors_per_track, heads_per_track
; output : abs_sector (CHS sector addr), abs_head (CHS head addr), abs_track (CHS track addr)
proj_e_lbachs:
    xor dx, dx       ; dx=0
    div WORD [sectors_per_track]
    inc dl
    mov BYTE [abs_sector], dl

    xor dx, dx       ; dx=0
    div WORD [heads_per_track]
    mov BYTE [abs_head], dl
    mov BYTE [abs_track], al

    ret

; read sectors
; input  : CX (number of sectors to read), AX (LBA addr to start from)
; output : ES:BX (loaded sector addr:offset)
proj_e_readsectors:
    proj_e_sectorsmain:
        mov di, 0x0005
    proj_e_sectorsloop:
        push ax
        push bx
        push cx
        call proj_e_lbachs

        mov ah, 0x02
        mov al, 0x01
        mov ch, BYTE [abs_track]
        mov cl, BYTE [abs_sector]
        mov dh, BYTE [abs_head]
        mov dl, BYTE [drive_number]

        int 13h
        jnc proj_e_sectorsdone
        xor ax, ax        ; ax=0
        int 13h
        dec di

        pop cx
        pop bx
        pop ax

        jnz proj_e_sectorsloop
        int 18h
    proj_e_sectorsdone:
        pop cx
        pop bx
        pop ax

        add bx, WORD [bytes_per_sector]
        inc ax
        loop proj_e_sectorsmain
        ret

; pad to 510 bytes (boot sector - 2)
times 510-($-$$) db 0
; standard boot signature
dw 0xAA55
