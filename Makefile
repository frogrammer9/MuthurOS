ASM=nasm
SRC_DIR=src
BUILD_DIR=build

CC=gcc
CC16=/usr/bin/watcom/binl64/wcc
LD16=/usr/bin/watcom/binl64/wlink

.PHONY: all image kernel bootloader always clean

all: image

image: $(BUILD_DIR)/muthur.img

$(BUILD_DIR)/muthur.img: bootloader kernel
	dd if=/dev/zero of=$(BUILD_DIR)/muthur.img bs=512 count=2880
	mkfs.fat -F 12 -n "NBOS" $(BUILD_DIR)/muthur.img
	dd if=$(BUILD_DIR)/boot/boot.bin of=$(BUILD_DIR)/muthur.img conv=notrunc
	mcopy -i $(BUILD_DIR)/muthur.img $(BUILD_DIR)/boot/boots2.bin "::boots2.bin"
	mcopy -i $(BUILD_DIR)/muthur.img $(BUILD_DIR)/kernel/kernel.bin "::kernel.bin"

bootloader: stage1 stage2

stage1: $(BUILD_DIR)/boot/boot.bin

$(BUILD_DIR)/boot/boot.bin: always
	$(MAKE) -C $(SRC_DIR)/boot BUILD_DIR=$(abspath $(BUILD_DIR))

stage2: $(BUILD_DIR)/boot/boots2.bin

$(BUILD_DIR)/boot/boots2.bin: always
	$(MAKE) -C $(SRC_DIR)/boot/boots2 BUILD_DIR=$(abspath $(BUILD_DIR))

kernel: $(BUILD_DIR)/kernel/kernel.bin

$(BUILD_DIR)/kernel/kernel.bin: always
	$(MAKE) -C $(SRC_DIR)/kernel BUILD_DIR=$(abspath $(BUILD_DIR))

always: 
	mkdir -p $(BUILD_DIR)

clear:
	rm -rf $(BUILD_DIR)/*
