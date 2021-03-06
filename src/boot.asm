bits 16
org 0x7c00

start:
    jmp main

%include "std/stdio.asm"
%include "std/readdisk.asm"

data:
    ; strings
    title               db 'Project E', 13, 10, '=========', 13, 10, 13, 10, 0
    msg_info            db '[Bootloader] Started in 16 bits (real mode)', 13, 10, 0
    msg_kernel_loaded   db '[Bootloader] Kernel loaded into RAM @ 0x1000', 13, 10, 0
    msg_kernel_load_err db '[!] [Bootloader] Could not load kernel', 13, 10, 0
    ; parameters
    KERNEL_BLOCK_START equ      1
    KERNEL_BLOCKS_SIZE equ     32
    KERNEL_SEGMENT     equ 0x0100    ; 0x0100:0x0000=0x1000

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
    print title
    print msg_info

    ; loading kernel
    load_file KERNEL_BLOCK_START, KERNEL_SEGMENT, KERNEL_BLOCKS_SIZE

    jnc .jump_to_kernel

.kernel_loading_error:
    print msg_kernel_load_err
    cli
    hlt

.jump_to_kernel:
    print msg_kernel_loaded
    jmp KERNEL_SEGMENT:0x0000

; pad to 510 bytes (boot sector - 2)
times 510-($-$$) db 0
; standard boot signature
dw 0xAA55
