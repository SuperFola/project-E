%ifndef stdio_h_1337
%define stdio_h_1337

%macro mystosb16_di 0
    mov [di], al
    inc di
%endmacro

bits 16

STACK_SEG16 equ  0x9000
STACK_SEG32 equ 0x90000
STACK_SIZE  equ  0xffff
SCREEN_SEG  equ  0xb800

; routine for outputting 'si' register on the screen
proj_e_print16:
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
proj_e_reboot16:
    db 0x0ea         ; sending us to the end of the memory, to reboot
    dw 0x0000
    dw 0xffff

; routine to get a key press
proj_e_waitkeypress16:
    mov ah, 0
    int 16h          ; BIOS keyboard service
    ret

; ----------------------------------------------------------
; Routine: Get String from User
; Waits for a complete string of user input and puts it in buffer.
; Sensitive for backspace and Enter buttons
; Input    1. Buffer in DI, character limit in CH
; Output   2. Input char in buffer
; ----------------------------------------------------------
proj_e_get_user_input:
    cld
    xor cl, cl       ; CL will be our counter to keep track of the number of characters the user has entered.
                     ; XORing cl by itself will set it to zero.
.get_char_and_add_to_buffer:
    xor ah, ah     ; We use bios interrupt 16h to capture user input.
                   ; AH=0 is an option for 16h that tells the interrupt to read the user input character
    int 16h        ; call interrupt. Stores read character in AL

    ; backspace button listener
    cmp al, 0x08   ; compares user input to the backspace button, stores result in Carry Flag
    je .backspace_pressed    ; if the results of the compare is 1, go to subroutine .backspace_pressed

    ; enter button listener
    cmp al, 0x0D   ; compares user input to enter button
    je .enter_pressed        ; go to appropriate subroutine for enter button

    ; input counter
    cmp cl, ch         ; Has the user entered 'ch' bytes yet? (buffer limit is in register ch)
    je .buffer_overflow

    ; User input is normal character

    ; print input
    mov ah, 0x0E   ; Teletype mode
    int 10h        ; Print interrupt

    ; puts character in buffer
    mystosb16_di

    inc cl         ; increment counter
    jmp .get_char_and_add_to_buffer    ; recurse

; // Subroutines
.backspace_pressed:
    cmp cl, 0      ; no point erasing anything if no input has been entered
    je .get_char_and_add_to_buffer   ; ignore backspace press

    ; Delete last input character from buffer
        ; When you use stosb, movsb or similar functions, the system implicitly uses the SI and DI registers.
    dec di           ; Therefore we need to decrement di to get to the last input character and erase it.
    mov byte [di], 0 ; Erases the byte at location [di]
    dec cl           ; decrement our counter

    ; Erase character from display
    mov ah, 0x0E   ; Teletype mode again
    mov al, 0x08   ; Backspace character
    int 10h

    mov al, ' '    ; Empty character to print
    int 10h

    mov al, 0x08
    int 10h

    jmp .get_char_and_add_to_buffer    ; go back to main routine

; enter button pressed. Jump to exit
.enter_pressed:
    jmp .exit_routine

; buffer overflow (buffer is full). Don't accept any more chars and exit routine.
.buffer_overflow:
    jmp .exit_routine

.exit_routine:
    mov al, 0       ; end of user input signal
    mystosb16_di

    mov ah, 0x0E
    mov al, 0x0D    ; new line
    int 0x10
    mov al, 0x0A
    int 0x10

    ret             ; exit entire routine

; ----------------------------------------------------------
; Routine: Compare equality of two strings
; Waits for a complete string of user input and puts it in buffer.
; Sensitive for backspace and Enter buttons
; Input    1. String1 in SI    2. String2 in DI
; Output   1. result in carry flag
; ----------------------------------------------------------
proj_e_compare_string:
  .compare_next_character:      ; a loop that goes character by character
    mov al, [si]      ; focus on next byte in si
    mov bl, [di]      ; focus on next byte in di
    cmp al, bl
    jne .conclude_not_equal       ; if not equal, conclude and exit

    ; we know: two bytes are equal

    cmp al, 0         ; did we just compare two zeros?
    je .conclude_equal         ; if yes, we've reached the end of the strings. They are equal.

    ; increment counters for next loop
    inc di
    inc si
    call .compare_next_character

  .conclude_equal:
    stc              ; sets the carry flag (meaning that they ARE equal)
    jmp .done


  .conclude_not_equal:
    clc              ; clears the carry flag (meaning that they ARE NOT equal)
    jmp .done

  .done:
    ret

%endif
