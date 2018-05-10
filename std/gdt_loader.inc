bits 16

proj_e_installGDT16:
    ; cli         ; clear interrupts

    xor eax, eax
    xor ebx, ebx

    mov ax, ds           ; save data segment in ax
    shl eax, 4           ; eax*16=linear address of the segment base
    add eax, gdt         ; adding GDT offset
    mov dword [gdt_table + 2], eax   ; saving in the GDTR

    lgdt [gdt_table]  ; load GDT into GDTR

    ; reinit ax, bx, cx, dx registers
    xor ax, ax
    xor bx, bx
    xor cx, cx
    xor dx, dx

    ; reinit cs and ds
    jmp short .gdtrc

.gdtrc:
    ; sti         ; enable interrupts
    ret         ; we are done

%include "std/gdt.inc"
