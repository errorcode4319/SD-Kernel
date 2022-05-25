#ENV
ASM32 = nasm 
CC32 = gcc -c -m32 -ffreestanding
LD32 = ld -melf_i386 -T ../elf_i386.x -nostdlib -e Main -Ttext 0x10200
OBJCOPY32 = objcopy -j .text -j .data -j .rodata -j .bss -S -O binary 

OBJ_DIR = build
SRC_DIR = src


all: setup kernel32.bin

setup:
	mkdir -p $(OBJ_DIR)


$(OBJ_DIR)/entry.bin: $(SRC_DIR)/entry.s 
	$(ASM32) -o $@ $<


dep:
	make -C $(OBJ_DIR) -f ../Makefile internal-deps


exe-internal-build: dep
	make -C $(OBJ_DIR) -f ../Makefile kernel32.elf 


$(OBJ_DIR)/kernel32.elf.bin: exe-internal-build 
	$(OBJCOPY32) $(OBJ_DIR)/kernel32.elf $@ 


kernel32.bin: $(OBJ_DIR)/entry.bin $(OBJ_DIR)/kernel32.elf.bin
	cat $^ > $@


clean:
	rm -f *.bin 
	rm -f $(OBJ_DIR)/*.*


C_ENTRY_OBJ = Main.o
C_SRCS = $(wildcard ../$(SRC_DIR)/*.c)
ASM_SRCS = $(wildcard ../$(SRC_DIR)/*.asm)
C_OBJS = $(subst Main.o, , $(notdir $(patsubst %.c,%.o,$(C_SRCS))))
ASM_OBJS = $(notdir $(patsubst %.asm,%.o,$(ASM_SRCS)))

%.o: ../$(SRC_DIR)/%.c
	$(CC32) -c $<


%.o: ../$(SRC_DIR)/%.asm 
	$(ASM32) -f elf32 -o $@ $<


internal-deps:
	$(CC32) -MM $(C_SRCS) > Dependency.dep


kernel32.elf: $(C_ENTRY_OBJ) $(C_OBJS) $(ASM_OBJS)
	$(LD32) -o $@ $^


ifeq (Dependency.dep, $(wildcard Dependency.dep))
include Dependency.dep
endif 