%ifndef proj_e_macros_asm
%define proj_e_macros_asm

; --------------------------
;         Strings
; --------------------------

%macro print 1
    push si
        mov si, %1
        call proj_e_print
    pop si
%endmacro

%macro printhex 1
    mov ax, %1
    call proj_e_print_hex
%endmacro

%macro mystosb 1
    mov [%1], al
    inc %1
%endmacro

%macro input 2
    mov di, %1
    mov ch, %2
    mov bl, 0x00
    call proj_e_get_user_input
%endmacro

%macro getpass 2
    mov di, %1
    mov ch, %2
    mov bl, 0x01
    call proj_e_get_user_input
%endmacro

%macro strcmp 2
    mov di, %1
    mov si, %2
    call proj_e_compare_string
%endmacro

; --------------------------
;        Video Mode
; --------------------------

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

%macro move_cursor 1
    mov cx, %1
    call proj_e_move_cursor
%endmacro

%endif
