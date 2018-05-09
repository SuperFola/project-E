#!/bin/bash

if [ ! -d "cdiso" ]; then
    mkdir cdiso
fi

if [ ! -d "build" ]; then
    mkdir build
fi

if [ "$#" -eq "1" ] && [ "$1" == "qemu" ]; then
    nasm -f bin -o build/kernel.bin kernel.asm
    echo Kernel built

    nasm -f bin -o build/bootloader.bin boot.asm
    echo Bootloader built

    cat build/bootloader.bin build/kernel.bin > build/proj_e-bootker.bin
    dd status=noxfer conv=notrunc if=build/proj_e-bootker.bin of=build/floopy_proj_e-bootker.fda
    echo Floppy drive built

    qemu-system-x86_64 -fda build/floopy_proj_e-bootker.fda
    exit 0
else
    echo Building ISO
    echo Need to fix the command before continuing ! && exit 1

    cd bootloader && ./build.sh && cd ..
    cp bootloader/build/bootloader.flp cdiso/

    mkisofs -o build/project_e.iso -b bootloader.flp cdiso/

    exit 0
fi

# if we are here we probably missed a "if"
echo "No  argument : build the ISO"
echo "1st argument : qemu   => after having built the floppy, run qemu"
exit 1
