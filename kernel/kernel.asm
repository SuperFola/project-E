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
	call print
	; jump here
	jmp $

print:
	lodsb
	or al, al
	jz printdone
	mov ah, 0eh
	int 10h
	jmp print
printdone:
	ret

times 512-($-$$) db 0
