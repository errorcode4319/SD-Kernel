all: BootLoader Kernel32 OS.img


BootLoader:
	@echo ========== Build Boot Loader ==========
	make -C boot


Kernel32:
	@echo ========== Build Test Kernel ==========
	make -C kernel32


OS.img: boot/bootloader.bin kernel32/kernel32.bin
	@echo ========== Build Disk Image ==========
	cat  $^ > OS.img 


clean:
	make -C boot clean 
	make -C kernel32 clean 
	rm -f OS.img 