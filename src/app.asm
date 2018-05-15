; in which mode our application will be running
bits 16

; entry point of our application
start:
    jmp main

; all the includes we must do will be right there
%include "std/macros.asm"
%include "std/defines.asm"
; needed for print(), to change the colors of the screen, clear it,
; and move the cursor, input() and strcmp()
%include "std/string.asm"
%include "std/stdio.asm"
%include "std/video.asm"

; our variables will be right there
data:
    message db 'Hello world ! This a string terminated by \r\n', 13, 10, 0
    prompt  db '> ', 0
    new_line db 13, 10, 0

    ; MAXSIZE_BUFFER is the maximum size of our buffer
    MAXSIZE_BUFFER equ 72
    input_buffer times MAXSIZE_BUFFER db 0

    HELLO db 'hello', 0

; the code of our application will be right there
main:
    mov ax, cs
    mov ds, ax

    ; an handy macro print out a given message
    print message
    ; to get an input from the user, we must give both the buffer and its maximum size
    print prompt
    input input_buffer, MAXSIZE_BUFFER
    strcmp input_buffer, HELLO
    jc .end             ; jc means "jump carry". we want to jump if the carry flag is on
                        ; (activated if the two strings are identical)
                        ; to the end of our program, to avoid printing the input_buffer

    ; echo back what the user wrote if it isn't "hello"
    print input_buffer
    print new_line

.end:
    ; nothing more to do, we give back the control to the kernel !
    jmp KERNEL_LOAD_ADDRESS:0x0000

; to ensure our application fits in the 4kB
times 4096-($-$$) db 0
