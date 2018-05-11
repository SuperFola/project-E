all: image

image: build bootloader kernel
	@dd if=/dev/zero of=build/project_e.img bs=512 count=2880
	@dd status=noxfer conv=notrunc if=build/boot.bin   of=build/project_e.img bs=512 seek=0
	@dd status=noxfer conv=notrunc if=build/kernel.bin of=build/project_e.img bs=512 seek=1

build:
	@mkdir build

bootloader:
	@nasm -f bin -o build/boot.bin src/boot.asm

kernel:
	@nasm -f bin -o build/kernel.bin src/kernel.asm

app:
	@nasm -f bin -o build/app.bin src/app.asm

clean:
	@rm -f build/*.bin
	@rm -f iso/*

mrproper: clean
	@rm -rf build/
