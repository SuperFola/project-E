#!/bin/bash

if [ ! -d "cdiso" ]; then
    mkdir cdiso
fi

if [ "$#" -eq "1" ] &&  [ "$1" == "qemu" ]; then
    qemu-system-x86_64 -fda build/proj_e.img
    exit 0
else
    echo Building ISO
    echo Need to fix the command before continuing ! && exit 1

    mkisofs -o build/project_e.iso -b build/proj_e.img cdiso/

    exit 0
fi

# if we are here we probably missed a "if"
echo "No  argument : build the ISO"
echo "1st argument : qemu   => after having built the floppy, run qemu"
exit 1
