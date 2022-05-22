all: BootLoader Disk.img


BootLoader:
	@echo ========== Build Boot Loader ==========
	make -C 000-BootLoader


Kernel32:
	@echo ========== Build Test Kernel ==========
	make -C 001-Kernel32


Disk.img: BootLoader Kernel32
	@echo ========== Build Disk Image ==========
	cat 000-BootLoader/BootLoader.bin 001-Kernel32/TestOS.bin > SDos.img 


clean:
	make -C 000-BootLoader clean 
	make -C 001-Kernel32 clean 
	rm -f SDos.img 