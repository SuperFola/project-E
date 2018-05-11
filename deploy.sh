#!/bin/bash

if [ "$#" -eq "1" ]; then
    sudo dd if=iso/project_e.iso of=$1 bs=4M
else
    echo "Need a single argument : the disk where the ISO should be deployed" && exit 1
fi
