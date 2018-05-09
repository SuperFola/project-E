#!/bin/bash

if [ ! -d "cdiso" ]; then
	mkdir cdiso
fi

if [ ! -d "build" ]; then
	mkdir build
fi

if [ "$#" -ge "1" ]; then
	good=0
	if [ "$1" == "kerasm" ]; then
		cd kernel && ./build.sh asm && cd ..
		good=1
	else
		if [ "$1" == "kerc" ]; then
			cd kernel && ./build.sh c && cd ..
			good=1
		fi
	fi

	if [ "$good" -eq "1" ]; then
		cd bootloader && ./build.sh && cd ..
		cat bootloader/build/bootloader.bin kernel/build/kernel.bin > build/proj_e-bootker.bin
		dd status=noxfer conv=notrunc if=build/proj_e-bootker.bin of=build/floopy_proj_e-bootker.fda
	fi

	if [ "$#" -eq "2" ]; then
		if [ "$2" == "qemu" ]; then
			qemu-system-x86_64 -fda build/floopy_proj_e-bootker.fda
			exit 0
		fi
	fi
else
	echo Building ISO

	cd bootloader && ./build.sh && cd ..
	cp bootloader/build/bootloader.flp cdiso/

	echo Need to fix the command before continuing ! && exit 1
	mkisofs -o build/project_e.iso -b bootloader.flp cdiso/

	exit 0
fi

# if we are here we probably missed a "if"
echo "No  argument : build the ISO"
echo "1st argument : kerasm => build the bootloader and the asm kernel together"
echo "               kerc   => build the bootloader and the c kernel together"
echo "2nd argument : qemu   => after having built the floopy, run qemu"
exit 1
