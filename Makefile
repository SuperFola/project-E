all: image

image: build bootloader kernel app
	@dd if=/dev/zero of=build/project_e.img bs=512 count=2880
	@dd status=noxfer conv=notrunc if=build/boot.bin   of=build/project_e.img bs=512 seek=0
	@dd status=noxfer conv=notrunc if=build/kernel.bin of=build/project_e.img bs=512 seek=1
	@dd status=noxfer conv=notrunc if=build/app.bin    of=build/project_e.img bs=512 seek=33
	@echo project_e.img created

build:
	@mkdir build

bootloader:
	@nasm -f bin -o build/boot.bin src/boot.asm
	@echo Bootloader built

kernel:
	@nasm -f bin -o build/kernel.bin src/kernel.asm
	@echo Kernel built

app:
	@nasm -f bin -o build/app.bin src/app.asm
	@echo App built

clean:
	@rm -f build/*
	@rm -f iso/*
	@echo Build and iso folders cleaned

mrproper: clean
	@rm -rf build/
