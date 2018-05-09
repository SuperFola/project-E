bits 16
org 0

start:
	jmp main

	; 4K space after this bootloader
	; Effective addr=Segment*16 + Offset
	mov ax, 07C0h  ; ax=(location of the bootloader)/16
	add ax, 20h    ; skip over the size of the bootloader / 16
	mov ss, ax     ; ss=this location (beginning of our stack region)
	mov sp, 4096   ; ss:sp=4K (our stack)

	; set data segment to where we're loaded (to access implicitly the next 64K)
	mov ax, 07C0h
	mov ds, ax     ; ds=(location of the bootloader)/16

	; print our message
	mov si, message
	call proj_e_boot_print

	mov si, reboot_msg
	call proj_e_boot_print

	call proj_e_boot_getkeypress
	call proj_e_boot_reboot

	; cli            ; clear the interrupt flag (disable external interrupts)
	; hlt            ; halt the CPU (until next external interrupt)

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

	mov ax, 0x01       ; LBA number 1 for sector
	mov cx, 0x01       ; read one sector from the floppy disk
	mov bx, 0x200

	; call the read sectors function
	call proj_e_boot_readsectors
	; address ES offset BX returned from read sectors
	jmp 0x7e0:0

data:
	; strings
	message    db 'Hello World!',     13, 10, 0
	reboot_msg db 'Press any key to reboot ', 0
	; parameters
	sectors_per_track  dw  18
	heads_per_track    dw   2
	bytes_per_sector   dw 512
	drive_number       dw   0
	; variables
	abs_sector dw 0x00
	abs_head   dw 0x00
	abs_track  dw 0x00

; routine for outputting 'si' register on the screen
proj_e_boot_print:
	mov ah, 0Eh      ; specify int 10h (teletype output)
.printchar:
	lodsb            ; load byte from si into al, increment si
	cmp al, 0        ; is it the end of the string ?
	je .done         ; yes => quit ; no => continue
	int 10h          ; print the character
	jmp .printchar
.done:
	ret

; routine to reboot the machine
proj_e_boot_reboot:
	db 0x0ea         ; sending us to the end of the memory, to reboot
	dw 0x0000
	dw 0xffff

; routine to get a key press
proj_e_boot_getkeypress:
	mov ah, 0
	int 16h          ; BIOS keyboard service
	ret

; LBA to CHS
; input  : AX (LBA addr), sectors_per_track, heads_per_track
; output : abs_sector (CHS sector addr), abs_head (CHS head addr), abs_track (CHS track addr)
proj_e_boot_lbachs:
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
proj_e_boot_readsectors:
	proj_e_boot_sectorsmain:
		mov di, 0x0005
	proj_e_boot_sectorsloop:
		push ax
		push bx
		push cx
		call proj_e_boot_lbachs

		mov ah, 0x02
		mov al, 0x01
		mov ch, BYTE [abs_track]
		mov cl, BYTE [abs_sector]
		mov dh, BYTE [abs_head]
		mov dl, BYTE [drive_number]

		int 13h
		jnc proj_e_boot_sectorsdone
		xor ax, ax        ; ax=0
		int 13h
		dec di

		pop cx
		pop bx
		pop ax

		jnz proj_e_boot_sectorsloop
		int 18h
	proj_e_boot_sectorsdone:
		pop cx
		pop bx
		pop ax

		add bx, WORD [bytes_per_sector]
		inc ax
		loop proj_e_boot_sectorsmain
		ret

; pad to 510 bytes (boot sector - 2)
times 510-($-$$) db 0
; standard boot signature
dw 0xAA55
