#!/bin/bash

if [ "$#" -eq "1" ] &&  [ "$1" == "qemu" ]; then
    echo Running qemu
    qemu-system-x86_64 -fda build/project_e.img
    exit 0
else
    echo Building ISO
    if [ ! -d "iso" ]; then
        mkdir iso
    fi

    dd if=/dev/zero of=iso/floppy.img bs=512 count=2880  # creating a 512*2880 disk (size of a 1.44MB floppy)
    dd if=build/project_e.img of=iso/floppy.img seek=0 bs=512 count=33 conv=notrunc  # we are copying 33 sectors (33*512B)

    cd iso
    genisoimage -quiet -V "Project-E" -input-charset iso8859-1 -o project_e.iso -b floppy.img -hide floppy.img ./
    exit 0
fi

# if we are here we probably missed a "if"
echo "No  argument : build the ISO in cdiso/"
echo "1st argument : qemu   => after having built the floppy, run qemu"
exit 1
