%ifndef video_h_1337
%define video_h_1337

%define VIDMEM  0xb800   ; video memory
%define COLS        80   ; width and height of screen
%define LINES       25

%define CHAR_ATTR_BLACK    0
%define CHAR_ATTR_BLUE     1
%define CHAR_ATTR_GREEN    2
%define CHAR_ATTR_CYAN     3
%define CHAR_ATTR_RED      4
%define CHAR_ATTR_MAGENT   5
%define CHAR_ATTR_BROWN    6
%define CHAR_ATTR_LGREY    7
%define CHAR_ATTR_DGREY    8
%define CHAR_ATTR_LBLUE    9
%define CHAR_ATTR_LGREEN  10
%define CHAR_ATTR_LCYAN   11
%define CHAR_ATTR_LRED    12
%define CHAR_ATTR_LMAGENT 13
%define CHAR_ATTR_YELLOW  14
%define CHAR_ATTR_WHITE   15

%define CREATE_COLOUR(fg, bg) ((fg) + (bg) * 16)

%define CA_WHITE_ON_BLUE 0x3f

; Routine to clear the screen
; INPUT  : AH (color to use to clear the screen)
; OUTPUT : none
proj_e_clear_screen16:
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
proj_e_move_cursor16:
    mov dl, cl   ; set position of cursor
    mov dh, ch

    mov ah, 0x02  ; linked with int 0x10 : move cursor
    xor bh, bh    ; page number
    int 0x10

    ret

; avoid this, just testing some stuff
proj_e_init_vid_mem16:
    mov ax, VIDMEM
    mov es, ax     ; Set video segment to VIDMEM
    mov ax, 0x4020 ; colour + space character(0x20)
    mov cx, 2000   ; Number of cells to update 80*25=2000
    xor di, di     ; Video offset starts at 0 (upper left of screen)
    rep stosw      ; Store AX to CX # of words starting at ES:[DI]

    ret

%endif





