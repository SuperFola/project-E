#!/bin/bash

if [ ! -d "build" ]; then
	mkdir build
fi

if [ "$#" -eq "1" ]; then
	if [ "$1" == "asm" ]; then
		echo "Compiling Assembly Kernel"
		nasm -f bin -o build/kernel.bin kernel.asm
		echo "Build done"
	else
		if [ "$1" == "c" ]; then
			echo "Compiling C Kernel"
			gcc -m32 -ffreestanding -c kernel.c -o build/kernel.o
			nasm -f elf32 loader.asm -o build/loader.o
			ld -m elf_i386 -o build/kernel.elf -Ttext 0x1000 build/loader.o build/kernel.o
			objcopy -R .note -R .comment -S -O binary build/kernel.elf build/kernel.bin
			echo "Build done"
		else
			echo "Unrecognized argument. Try asm || c" && exit 1
		fi
	fi
else
	echo "One argument wanted : asm || c" && exit 1
fi
