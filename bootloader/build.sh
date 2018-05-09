#!/bin/bash

echo Building bootloader

if [ ! -d "build" ]; then
	mkdir build/
fi

nasm -f bin -o build/bootloader.bin boot.asm
dd conv=notrunc bs=512 count=1 if=build/bootloader.bin of=build/bootloader.flp

if [ "$#" -ge "1" ]; then
	qemu-system-x86_64 -fda build/bootloader.flp
fi
