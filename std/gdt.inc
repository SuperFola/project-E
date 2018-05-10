; Offset 0 in GDT: Descriptor code=0x00

gdt:
gdt_null:
    dd 0           ; null descriptor
    dd 0

; Offset 0x8 bytes from start of GDT: Descriptor code therfore is 0x08
CODE_DESC equ $-gdt  ; code descriptor
    dw 0FFFFh      ; limit low
    dw 0           ; base low
    db 0           ; base middle
    db 10011010b   ; access
    db 11001111b   ; granularity
    db 0           ; base high

; Offset 16 bytes (0x10) from start of GDT. Descriptor code therfore is 0x10
DATA_DESC equ $-gdt  ; data descriptor
    dw 0FFFFh      ; limit low (Same as code)
    dw 0           ; base low
    db 0           ; base middle
    db 10010010b   ; access
    db 11001111b   ; granularity
    db 0           ; base high

gdt_end:
gdt_table:
    dw gdt_end - gdt - 1      ; limit (Size of GDT)
    dd gdt                    ; base of GDT
