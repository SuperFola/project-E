#!/bin/bash

if [ ! -d "build" ]; then
	mkdir build
fi

if [ "$#" -eq "1" ]; then
	if [ "$1" == "asm" ]; then
		echo "Compiling Assembly Kernel"
		nasm -f bin -o build/kernel.bin kernel.asm
	else
		if [ "$1" == "c" ]; then
			echo "Compiling C Kernel"
			gcc -ffreestanding -c kernel.c -o build/kernel.o
			ld -o build/kernel.bin -Ttext 0x8000 build/kernel.o --oformat binary
		else
			echo "Unrecognized argument. Try asm || c" && exit 1
		fi
	fi
else
	echo "One argument wanted : asm || c" && exit 1
fi
