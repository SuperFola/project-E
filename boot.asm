bits 16

start:
    jmp main

%include "std/stdio.inc"

data:
    ; strings
    new_line db 13, 10, 0
    message  db 'Project E', 13, 10, '=========', 13, 10, 13, 10, '[Bootloader ready] Press any key to load the kernel', 0
    ; parameters
    ADDR_KERNEL_OFFSET equ 512
    KERNEL_BLOCKS_SIZE equ   4
    sectors_per_track  dw   18
    heads_per_track    dw    2
    bytes_per_sector   dw  512
    drive_number       dw    0
    ; variables
    abs_sector dw 0x00
    abs_head   dw 0x00
    abs_track  dw 0x00

main:
    cli              ; move registers for offset of BIOS 0x7c0 load point
    mov ax, 0x7c0    ; offset
    mov ds, ax
    mov es, ax

    mov ax, STACK_SEG16          ; init the stack
    mov ss, ax
    mov sp, STACK_SIZE
    sti

    ; display message on startup
    mov si, message
    call proj_e_print16
    call proj_e_waitkeypress16
    mov si, new_line
    call proj_e_print16

    ; prepare to load the kernel
    mov ax, 0x01                  ; LBA number 1 for sector
    mov cx, KERNEL_BLOCKS_SIZE    ; read sectors from the floppy disk
    mov bx, ADDR_KERNEL_OFFSET
    ; call the read sectors function
    call proj_e_readsectors

    ; address ES offset BX returned from read sectors (call kernel)
    jmp 0x7e0:0

; LBA to CHS
; input  : AX (LBA addr), sectors_per_track, heads_per_track
; output : abs_sector (CHS sector addr), abs_head (CHS head addr), abs_track (CHS track addr)
proj_e_lbachs:
    xor dx, dx       ; dx=0
    div word [sectors_per_track]
    inc dl
    mov byte [abs_sector], dl

    xor dx, dx       ; dx=0
    div word [heads_per_track]
    mov byte [abs_head], dl
    mov byte [abs_track], al

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
        mov ch, byte [abs_track]
        mov cl, byte [abs_sector]
        mov dh, byte [abs_head]
        mov dl, byte [drive_number]

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

        add bx, word [bytes_per_sector]
        inc ax
        loop proj_e_sectorsmain
        ret

; pad to 510 bytes (boot sector - 2)
times 510-($-$$) db 0
; standard boot signature
dw 0xAA55
