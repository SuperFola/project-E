all: image

image: build bootloader stage2 kernel app
	@dd if=/dev/zero of=build/project_e.img bs=512 count=2880
	@dd status=noxfer conv=notrunc if=build/boot.bin   of=build/project_e.img bs=512 seek=0
	@dd status=noxfer conv=notrunc if=build/stage2.bin of=build/project_e.img bs=512 seek=1
	@dd status=noxfer conv=notrunc if=build/kernel.bin of=build/project_e.img bs=512 seek=3
	@dd status=noxfer conv=notrunc if=build/app.bin    of=build/project_e.img bs=512 seek=35
	@echo project_e.img created

build:
	@mkdir build

bootloader:
	@nasm -f bin -o build/boot.bin src/boot.asm
	@echo Bootloader built

stage2:
	@nasm -f bin -o build/stage2.bin src/stage2.asm
	@echo Stage 2 built

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
