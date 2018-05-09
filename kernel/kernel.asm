bits 16
org 0

start:
	jmp main

data:
	message db 'Kernel loaded', 13, 10, 0

main:
	mov ax, cs
	mov ds, ax

	mov si, message
	call proj_e_boot_print
	; jump here
	jmp $

times 512-($-$$) db 0
