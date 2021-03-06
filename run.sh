#!/bin/bash

if [ "$#" -ge "1" ] &&  [ "$1" == "qemu" ]; then
    echo Running qemu
    debug_options="-d int,cpu_reset,guest_errors -no-reboot -no-shutdown"
    command="qemu-system-i386 -drive format=raw,if=floppy,index=0,file=build/project_e.img -m 128 -s "
    if [ "$#" -eq "2" ] && [ "$2" == "debug" ]; then
        command=$command$debug_options
    fi
    $command || exit 0
else
    echo Building ISO
    if [ ! -d "iso" ]; then
        mkdir iso
    else
        # clean working directory
        rm -rf iso/
        mkdir iso
    fi

    dd if=/dev/zero of=iso/floppy.img bs=512 count=2880  # creating a 512*2880 disk (size of a 1.44MB floppy)
    dd if=build/project_e.img of=iso/floppy.img seek=0 bs=512 count=87 conv=notrunc  # we are copying 87 sectors
    # 1 for the Bootloader
    # 32 for the Kernel
    # 64 for the 8 apps

    #cd iso
    #genisoimage -quiet -V "Project-E" -input-charset iso8859-1 -c boot.cat -l -R -J \
               # -boot-info-table -no-emul-boot -boot-load-size 4 \
    #            -o project_e.iso -b floppy.img -hide floppy.img ./
    exit 0
fi

# if we are here we probably missed a "if"
echo "No  argument : build the ISO in cdiso/"
echo "1st argument : qemu   => after having built the floppy, run qemu"
echo "2nd argument : debug  => to run qemu with debug options"
exit 1
