#!/bin/bash

echo Building iso

if [ ! -d "cdiso" ]; then
	mkdir cdiso
fi

if [ ! -d "build" ]; then
	mkdir build
fi

cd bootloader && ./build.sh && cd ..
cp bootloader/build/bootloader.flp cdiso/

echo Need to fix the command before continuing ! && exit 1
mkisofs -o build/project_e.iso -b bootloader.flp cdiso/
