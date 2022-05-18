all: BootLoader.bin


BootLoader.bin: bootloader.asm
	nasm -o BootLoader.bin bootloader.asm


clean:
	rm -f BootLoader.bin 