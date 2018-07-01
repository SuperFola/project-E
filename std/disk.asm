%ifndef proj_e_disk_asm
%define proj_e_disk_asm

; parameters
sectors_per_track dw  18
heads_per_track   dw   2
bytes_per_sector  dw 512
drive_number      dw   0
msg_error_reading_floppy db '[!] Error while reading floppy', 13, 10, 0
msg_error_writing_floppy db '[!] Error while writing to floppy', 13, 10, 0
; variables
abs_sector        dw   0
abs_head          dw   0
abs_track         dw   0
lba_number        dw   0
destination       dw   0

; Routine to convert a LBA (Logical Block Addresing) to CHS (Cylinder/Head/Sector)
; INPUT  : AX (LBA addr), sectors_per_track, heads_per_track
; OUTPUT : abs_sector (CHS sector addr), abs_head (CHS head addr), abs_track (CHS track addr)
proj_e_lbachs:
    xor dx, dx
    div word [sectors_per_track]
    inc dl
    mov byte [abs_sector], dl

    xor dx, dx
    div word [heads_per_track]
    mov byte [abs_head], dl
    mov byte [abs_track], al

    ret

%endif
