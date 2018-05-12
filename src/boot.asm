bits 16
org 0x7c00

start:
    jmp main

%include "std/stdio.asm"

data:
    ; strings
    new_line db 13, 10, 0
    title    db 'Project E', 13, 10, '=========', 13, 10, 13, 10, 0
    message  db '[Bootloader] Press any key to load bootloader', 0
    msg_kernel_load_err db '[!] [Bootloader] Could not load bootloader', 13, 10, 0
    ; parameters
    KERNEL_BLOCK_START equ     1
    KERNEL_BLOCKS_SIZE equ    32  ; 32*512B=16384B
    KERNEL_SEGMENT     equ 0x500

main:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax

    ; init the stack
    mov ss, ax
    mov sp, 0x7c00
    sti

    ; display message on startup
    mov si, title
    call proj_e_print16
    mov si, message
    call proj_e_print16
    call proj_e_waitkeypress16
    mov si, new_line
    call proj_e_print16

    ; prepare to load the kernel
    mov ah, 2                        ; sectors to read
    mov al, KERNEL_BLOCKS_SIZE       ; number of blocks to read
    push word KERNEL_SEGMENT         ; where it will be loaded
    pop es
    xor bx, bx                       ; reset bx to 0
    mov cx, KERNEL_BLOCK_START + 1   ; sector count start from 1
    mov dx, 0
    int 0x13                         ; call interrupt
                                     ; Writes error to Carry flag
    jnc .jump_to_kernel              ; loading success, no error in carry flag

.kernel_loading_error:
    mov si, msg_kernel_load_err
    call proj_e_print16
    cli
    hlt

.jump_to_kernel:
    jmp KERNEL_SEGMENT:0

; pad to 510 bytes (boot sector - 2)
times 510-($-$$) db 0
; standard boot signature
dw 0xAA55
