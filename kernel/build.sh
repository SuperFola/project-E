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
			gcc -m32 -ffreestanding -c -o build/kernel.o kernel.c -lgcc
			#nasm -f elf32 loader.asm -o build/loader.o
			ld -melf_i386 -Tlinker.ld -nostdlib --nmagic -o build/kernel.elf build/kernel.o
			objcopy -O binary build/kernel.elf build/kernel.o
			echo "Build done"
		else
			echo "Unrecognized argument. Try asm || c" && exit 1
		fi
	fi
else
	echo "One argument wanted : asm || c" && exit 1
fi
