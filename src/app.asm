; in which mode our application will be running
bits 16

; entry point of our application
start:
    jmp main

; all the includes we must do will be right there
%include "std/stdio.asm"
%include "std/video.asm"

; our variables will be right there
data:
    message db 'Hello world ! This a string terminated by \r\n', 13, 10, 0

; the code of our application will be right there
main:
    ; an handy macro print out a given message
    print(message)

; to ensure our application fits in the 4kB
times 4096-($-$$) db 0
