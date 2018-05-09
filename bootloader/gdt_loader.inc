bits 16

proj_e_installGDT16:
    cli         ; clear interrupts
    pusha       ; save registers
    lgdt [toc]  ; load GDT into GDTR
    sti         ; enable interrupts
    popa        ; restore registers
    ret         ; we are done

%include "gdt.inc"
