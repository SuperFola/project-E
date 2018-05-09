bits 16

proj_e_installGDT16:
    cli         ; clear interrupts
    pusha       ; save registers
    lgdt [toc]  ; load GDT into GDTR
    sti         ; enable interrupts
    popa        ; restore registers
    ret         ; we are done

%include "std/gdt.inc"

%define CODE_DESC 0x08
%define DATA_DESC 0x10
