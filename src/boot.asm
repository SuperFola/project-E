bits 16
org 0x7c00

start:
    jmp main

%include "std/stdio.asm"
%include "std/filesystem.asm"

data:
    ; strings
    new_line db 13, 10, 0
    title    db 'Project E', 13, 10, '=========', 13, 10, 13, 10, 0
    message  db '[Bootloader] Press any key to load kernel', 0
    msg_kernel_loaded   db '[Bootloader] Kernel loaded', 13, 10, 0
    msg_kernel_load_err db '[!] [Bootloader] Could not load kernel', 13, 10, 0
    msg_app_loaded      db '[Bootloader] App loaded', 13, 10, 0
    msg_app_load_err    db '[!] [Bootloader] Could not load app', 13, 10, 0

    ; parameters
    KERNEL_BLOCK_START equ      1
    KERNEL_BLOCKS_SIZE equ     32  ; 32*512B=16384B
    KERNEL_SEGMENT     equ 0x0100  ; 0x0100:0x0000=0x1000

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
    print message
    call proj_e_waitkeypress16
    print new_line

    ; prepare to load the kernel
    load_file KERNEL_BLOCKS_SIZE, KERNEL_SEGMENT, KERNEL_BLOCK_START
    jnc .jump_to_kernel              ; loading success, no error in carry flag

.kernel_loading_error:
    print msg_kernel_load_err
    cli
    hlt

.jump_to_kernel:
    print msg_kernel_loaded
    call KERNEL_SEGMENT:0x0000

; pad to 510 bytes (boot sector - 2)
times 510-($-$$) db 0
; standard boot signature
dw 0xAA55
