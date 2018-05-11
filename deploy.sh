#!/bin/bash

if [ "$#" -eq "1" ]; then
    sudo umount $1
    sudo mkdosfs -n 'PROJECT-E' -I $1 -F 32
    isohybrid iso/project_e.iso
    sudo dd if=iso/project_e.iso of=$1 bs=4M
    sync
    sudo eject $1
else
    echo "Need a single argument : the disk where the ISO should be deployed" && exit 1
fi
