%ifndef proj_e_string_asm
%define proj_e_string_asm

bits 16

; Routine to get a string from the user
; Waits for a complete string of user input and puts it in buffer
; Sensitive for backspace and Enter buttons
; INPUT  : DI (buffer address), CH (characters count limit), BL (a value != 0 will print * instead of the character)
; OUTPUT : input in buffer
proj_e_get_user_input:
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
    cmp bl, 0
    je .put_normal_char

    ; save al for later
    push ax
    mov al, '*'    ; if bl != 0, then replace the character with a '*'
    mov ah, 0x0e   ; Teletype mode
    int 0x10       ; Print interrupt
    pop ax

    jmp .next

.put_normal_char:
    mov ah, 0x0e   ; Teletype mode
    int 0x10       ; Print interrupt

.next:
    ; puts character in buffer
    mystosb di

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
    mystosb di

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
proj_e_compare_string:
.compare_next_character:
    ; a loop that goes character by character
    mov al, [si]      ; focus on next byte in si
    mov bl, [di]      ; focus on next byte in di
    cmp al, bl
    jne .conclude_not_equal       ; if not equal, conclude and exit

    ; we know: two bytes are equal
    cmp al, 0             ; did we just compare two zeros?
    je .conclude_equal    ; if yes, we've reached the end of the strings. They are equal.

    ; increment counters for next loop
    inc si
    inc di
    jmp .compare_next_character
.conclude_equal:
    ; sets the carry flag (meaning that they ARE equal)
    stc
    jmp .done
.conclude_not_equal:
    ; clears the carry flag (meaning that they ARE NOT equal)
    clc
.done:
    ret

; Routine to compare two strings, the second one MUST match the beginning of the first one
; INPUT  : SI (first string), DI (second string)
; OUTPUT : carry flag if strings are "equal"
; N.B.   : strings in SI and DI remain untouched
proj_e_compare_start_string:
.compare_next_character:
    ; a loop that goes character by character
    mov al, [si]      ; focus on next byte in si
    mov bl, [di]      ; focus on next byte in di

    cmp bl, 0
    je .conclude_equal

    cmp al, bl
    jne .conclude_not_equal

    ; increment counters for next loop
    inc si
    inc di
    jmp .compare_next_character
.conclude_equal:
    ; sets the carry flag (meaning that they ARE equal)
    stc
    jmp .done
.conclude_not_equal:
    ; clears the carry flag (meaning that they ARE NOT equal)
    clc
.done:
    ret

; Routine to get the size of a string
; INPUT  : SI (string to get size of)
; OUTPUT : AX (length)
proj_e_length_string:
    pusha
    mov cx, 0

.more:
    cmp byte [si], 0
    je .done

    inc si
    inc cx
    jmp .more

.done:
    mov word [.counter], cx
    popa
    mov ax, word [.counter]
    ret

    .counter dw 0

; Routine to tokenize a string "a b c d" (separator is given)
; INPUT  : SI (string to split), AL (single char separator)
; OUTPUT : DI (next token or 0 if none)
proj_e_tokenize_string:
    push si

.next_char:
    ; do we have a matching separator ?
    cmp byte [si], al
    je .return_token
    ; is this the end of the string ?
    cmp byte [si], 0
    jz .no_more

    ; move forward
    inc si
    jmp .next_char

.return_token:
    mov byte [si], 0
    inc si
    mov di, si
    pop si
    ret

.no_more:
    mov di, 0
    pop si
    ret

; Routine to convert a single hexdigit string to integer
; INPUT  : SI (string)
; OUTPUT : AL (number)
proj_e_hex_to_int:
    ; '0': 48, '1': 49, '2': 50, '3': 51, '4': 52, '5': 53, '6': 54, '7': 55, '8': 56, '9': 57
    ; 'a': 97, 'b': 98, 'c': 99, 'd': 100, 'e': 101, 'f': 102
    ; 'A': 65, 'B': 66, 'C': 67, 'D': 68, 'E': 69, 'F': 70

    ; get first char
    mov byte al, [si]
    ; if 48 <= al <= 57:
    cmp al, 48
    jl .error
    cmp al, 57
    jg .try_upper_letter
    ; then
    ; convert from ASCII to real number
    sub al, 48
    mov byte [.val], al
    jmp .end

.try_upper_letter:
    ; if 65 <= al <= 70
    cmp al, 65
    jl .error
    cmp al, 70
    jg .try_lower_letters
    ; then
    ; convert from ASCII to real number (+10, 'A' is the reference and 0xA == 10)
    sub al, 55
    mov byte [.val], al
    jmp .end

.try_lower_letters:
    ; if 97 <= al <= 102:
    cmp al, 97
    jl .error
    cmp al, 102
    jg .error
    ; then
    ; convert from ASCII to real number (+10, 'a' is the reference and 0xa == 10)
    sub al, 87
    mov byte [.val], al
    jmp .end

.end:
    clc
    jmp .done

.error:
    stc
    print .error_msg

.done:
    mov byte al, byte [.val]
    ret

    .val       db 0
    .error_msg db 'Could not convert hex-digit string to integer', 13, 10, 0

; Routine to convert a 2 hexdigits string to integer
; INPUT  : SI (string)
; OUTPUT : AL (number)
proj_e_2hex_to_int:
    ; if len(str) != 2:
    call proj_e_length_string
    cmp ax, 2
    ; then
    ; error
    jne .error
    ; else:
    ; go to end of string
    add si, ax
    dec si

    ; convert last digit from the right
    call proj_e_hex_to_int
    jc .error
    mov byte [.val], byte al
    dec si

    ; convert the 2nd digit and multiply it by 16
    call proj_e_hex_to_int
    jc .error
    mov byte ah, 0x00
    shl ax, 0x04
    add byte [.val], byte al

.end:
    clc
    jmp .done

.error:
    stc
    print .error_msg

.done:
    mov byte al, byte [.val]
    ret

    .val       db 0
    .error_msg db 'Could not convert 2hex-digits string to integer', 13, 10, 0

%endif
