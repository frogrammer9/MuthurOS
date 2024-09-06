BUILD_DIR?=build
ASM?=nasm

.PHONY: all kernel clean always

all: kernel

kernel: $(BUILD_DIR)/kernel/kernel.bin

$(BUILD_DIR)/kernel/kernel.bin: always
	$(ASM) kernel.s -f bin -o $(BUILD_DIR)/kernel/kernel.bin

clean:
	rm -f 

always:
	mkdir -p $(BUILD_DIR)/kernel
