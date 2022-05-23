all: BootLoader Kernel32 OS.img


BootLoader:
	@echo ========== Build Boot Loader ==========
	make -C 000-BootLoader


Kernel32:
	@echo ========== Build Test Kernel ==========
	make -C 001-Kernel32


OS.img: 000-BootLoader/BootLoader.bin 001-Kernel32/Kernel32.bin
	@echo ========== Build Disk Image ==========
	cat  $^ > OS.img 


clean:
	make -C 000-BootLoader clean 
	make -C 001-Kernel32 clean 
	rm -f OS.img 