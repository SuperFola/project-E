bits 16

proj_e_installGDT16:
    cli         ; clear interrupts

    xor eax, eax
    xor ebx, ebx

    mov ax, ds                 ; save data segment in ax
    shl eax, 4                 ; eax*16=linear address of the segment base
    add eax, gdt_start         ; adding GDT offset
    mov dword [toc + 2], eax   ; saving in the GDTR

    lgdt [toc]  ; load GDT into GDTR

    sti         ; enable interrupts
    ret         ; we are done

%include "std/gdt.inc"
