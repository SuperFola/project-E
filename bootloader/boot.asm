bits 16

start:
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

data:
	message db 'Hello World!', 13, 10, 0
	reboot_msg db 'Press any key to reboot ', 0

; routine for outputting 'si' register on the screen
proj_e_boot_print:
	mov ah, 0Eh    ; specify int 10h (teletype output)
.printchar:
	lodsb          ; load byte from si into al, increment si
	cmp al, 0      ; is it the end of the string ?
	je .done       ; yes => quit ; no => continue
	int 10h        ; print the character
	jmp .printchar
.done:
	ret

; routine to reboot the machine
proj_e_boot_reboot:
	db 0x0ea       ; sending us to the end of the memory, to reboot
	dw 0x0000
	dw 0xffff

; routine to get a key press
proj_e_boot_getkeypress:
	mov ah, 0
	int 16h        ; BIOS keyboard service
	ret

; pad to 510 bytes (boot sector - 2)
times 510-($-$$) db 0
; standard boot signature
dw 0xAA55
