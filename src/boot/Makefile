ASM?=nasm
SRC_DIR?=src
BUILD_DIR?=build

.PHONY: all clean always

all: stage1

stage1: $(BUILD_DIR)/boot.bin

$(BUILD_DIR)/boot.bin: always
	$(ASM) boot.s -f bin -o $(BUILD_DIR)/boot/boot.bin

clean:
	rm -f $(BUILD_DIR)/boot/boot.bin

always:
	mkdir -p $(BUILD_DIR)/boot
