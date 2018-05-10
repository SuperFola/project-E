all: image

image: build bootloader kernel
	cat build/bootloader.bin build/kernel.bin > build/proj_e.bin
	dd status=noxfer conv=notrunc if=build/proj_e.bin of=build/proj_e.img

build:
	mkdir build

bootloader:
	nasm -f bin -o build/bootloader.bin src/boot.asm

kernel:
	nasm -f bin -o build/kernel.bin src/kernel.asm

clean:
	rm -f build/*.bin

mrproper: clean
	rm -rf build/
