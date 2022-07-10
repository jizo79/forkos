OBJECTS = kernel.o kmain.o
KERNEL = kernel
OS = os
STAGE_FILE = stage2_eltorito

ISO_STRUCTURE = /iso/boot/grub
ISO_GRUB = /iso/boot/grub
ISO_BOOT = /iso/boot

SOURCES = src
BUILD = bin
INTERMEDIATE = intermediate
STAGE= stage
CONFIG = config

INTER_OBJECTS = $(patsubst %.o, $(INTERMEDIATE)/%.o, $(OBJECTS))

ASM = nasm
ASM_FLAGS = -felf32

LINKER_FLAGS = -T src/kernel/link.ld -melf_i386

CC = gcc
CC_FLAGS = -m32 -nostdlib -nostdinc -fno-builtin -fno-stack-protector -nostartfiles -nodefaultlibs
EMU = qemu-system-i386


all: prepare build run

debug: prepare build run_debug

prepare: clean configure

configure: $(CONFIG)
	mkdir $(BUILD)
	mkdir -p $(INTERMEDIATE)$(ISO_STRUCTURE)
	cp $(CONFIG)/menu.lst $(INTERMEDIATE)$(ISO_GRUB)/
	cp $(STAGE)/$(STAGE_FILE) $(INTERMEDIATE)$(ISO_GRUB)/
	cp $(CONFIG)/bochsrc.txt $(BUILD)/

build: kernel.elf $(OS).iso

kernel.elf: $(INTER_OBJECTS) src/kernel/link.ld
	ld $(LINKER_FLAGS) $(INTER_OBJECTS) -o $(INTERMEDIATE)/$(KERNEL).elf
	cp $(INTERMEDIATE)/$(KERNEL).elf $(INTERMEDIATE)/$(ISO_BOOT)/

$(INTERMEDIATE)/%.o: src/kernel/%.c
	$(CC) $(CC_FLAGS) $< -c -o $@

$(INTERMEDIATE)/%.o: src/kernel/%.s 
	$(ASM) $(ASM_FLAGS) $< -o $@

$(OS).iso: kernel.elf
	genisoimage -R 					\
	-b boot/grub/stage2_eltorito 	\
	-no-emul-boot 					\
	-boot-load-size 4 				\
	-A $(OS) 						\
	-input-charset utf8 			\
	-quiet 							\
	-boot-info-table 				\
	-o $(BUILD)/$(OS).iso 			\
	$(INTERMEDIATE)/iso
		
run: $(OS).iso
	qemu-system-i386 -cdrom bin/os.iso

run_debug: $(OS).iso
	qemu-system-i386 -cdrom bin/os.iso -monitor stdio

clean:
	rm -fr $(BUILD)
	rm -fr $(INTERMEDIATE)
