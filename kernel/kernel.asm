bits 16
org 0

start:
	jmp main

data:
	message db 'Kernel loaded', 13, 10, 0

main:
	mov si, message
	call proj_e_boot_print
	; jump here
	jmp $

times 510-($-$$) db 0
dw 0xAA55
