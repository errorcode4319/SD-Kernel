all: BootLoader Disk.img


BootLoader:
	make -C 000-BootLoader


Disk.img: 000-BootLoader/BootLoader.bin
	cp 000-BootLoader/BootLoader.bin Disk.img 


clean:
	make -C 000-BootLoader clean 
	rm -f Disk.img 