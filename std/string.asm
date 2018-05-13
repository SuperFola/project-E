%ifndef string_asm
%define string_asm

bits 16

%macro input 2
    mov di, %1
    mov ch, %2
    call proj_e_get_user_input16
%endmacro

%macro strcmp 2
    mov di, %1
    mov si, %2
    call proj_e_compare_string16
%endmacro

; Routine to get a string from the user
; Waits for a complete string of user input and puts it in buffer
; Sensitive for backspace and Enter buttons
; INPUT  : DI (buffer address), CH (characters count limit)
; OUTPUT : input in buffer
proj_e_get_user_input16:
    cld              ; clearing direction flag
    xor cl, cl       ; CL will be our counter to keep track of the number of characters the user has entered.
                     ; XORing cl by itself will set it to zero.
.get_char_and_add_to_buffer:
    xor ah, ah     ; We use bios interrupt 0x16 to capture user input.
                   ; AH=0 is an option for 0x16 that tells the interrupt to read the user input character
    int 0x16       ; call interrupt. Stores read character in AL

    ; backspace button listener
    cmp al, 0x08   ; compares user input to the backspace button, stores result in Carry Flag
    je .backspace_pressed    ; if the results of the compare is 1, go to subroutine .backspace_pressed

    ; enter button listener
    cmp al, 0x0d   ; compares user input to enter button
    je .enter_pressed        ; go to appropriate subroutine for enter button

    ; input counter
    cmp cl, ch         ; Has the user entered 'ch' bytes yet? (buffer limit is in register ch)
    je .buffer_overflow

    ; User input is normal character
    ; print input
    mov ah, 0x0e   ; Teletype mode
    int 0x10       ; Print interrupt

    ; puts character in buffer
    mystosb16_di

    inc cl         ; increment counter
    jmp .get_char_and_add_to_buffer    ; recurse

.backspace_pressed:
    cmp cl, 0      ; no point erasing anything if no input has been entered
    je .get_char_and_add_to_buffer   ; ignore backspace press

    ; Delete last input character from buffer
    ; When you use stosb, movsb or similar functions, the system implicitly uses the SI and DI registers.
    dec di           ; Therefore we need to decrement di to get to the last input character and erase it.
    mov byte [di], 0 ; Erases the byte at location [di]
    dec cl           ; decrement our counter

    ; Erase character from display
    mov ah, 0x0e   ; Teletype mode again
    mov al, 0x08   ; Backspace character
    int 0x10

    mov al, ' '    ; Empty character to print
    int 0x10

    mov al, 0x08
    int 0x10

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

    mov ah, 0x0e
    mov al, 0x0d    ; new line
    int 0x10
    mov al, 0x0a
    int 0x10

    ret             ; exit entire routine

; Routine to compare equality of two strings
; INPUT  : SI (first string address), DI (second string address)
; OUTPUT : carry flag on if strings are equal
; N.B.   : strings in SI and DI remain untouched
proj_e_compare_string16:
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