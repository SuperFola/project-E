%ifndef proj_e_video_asm
%define proj_e_video_asm

bits 16

%include "std/macros.asm"

; Routine to clear the screen
; INPUT  : AH (color to use to clear the screen)
; OUTPUT : none
proj_e_clear_screen:
    mov bx, VIDMEM
    mov es, bx
    mov al, ' '
    mov cx, 2000   ; COLS*LINES
    xor di, di     ; video offset=0
    rep stosw

    ret

; Routine to move the cursor on the screen
; INPUT  : CH (y position), CL (x position)
; OUTPUT : none
proj_e_move_cursor:
    mov dl, cl   ; set position of cursor
    mov dh, ch

    mov ah, 0x02  ; linked with int 0x10 : move cursor
    xor bh, bh    ; page number
    int 0x10

    ret

; avoid this, just testing some stuff
proj_e_init_vid_mem:
    mov ax, VIDMEM
    mov es, ax     ; Set video segment to VIDMEM
    mov ax, 0x4020 ; colour + space character(0x20)
    mov cx, 2000   ; Number of cells to update 80*25=2000
    xor di, di     ; Video offset starts at 0 (upper left of screen)
    rep stosw      ; Store AX to CX # of words starting at ES:[DI]

    ret

%endif
