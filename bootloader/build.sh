#!/bin/bash

mkdir build/
nasm -f bin -o build/bootloader.bin boot.asm
dd conv=notrunc bs=512 count=1 if=build/bootloader.bin of=build/bootloader.flp
qemu -fda build/bootloader.flp -curses
