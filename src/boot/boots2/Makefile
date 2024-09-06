CC16?=wcc
LD16?=wlink
ASM?=nasm
BUILD_DIR?=build

CC16FLAGS=-4 -d3 -s -wx -ms -zl -zq

SRC_C=$(wildcard *.c)
SRC_S=$(wildcard *.s)

OBJ_C=$(patsubst %.c, $(BUILD_DIR)/boot/s2/c/%.obj, $(SRC_C))
OBJ_S=$(patsubst %.s, $(BUILD_DIR)/boot/s2/s/%.obj, $(SRC_S))

.PHONY: all clear always stage2

all: stage2

stage2: $(BUILD_DIR)/boot/boots2.bin

$(BUILD_DIR)/boot/boots2.bin: $(OBJ_C) $(OBJ_S)
	$(LD16) NAME $(BUILD_DIR)/boot/boots2.bin FILE \{ $(OBJ_C) $(OBJ_S) \} OPTION MAP=$(BUILD_DIR)/boot/stage2.map @linker.lnk

$(BUILD_DIR)/boot/s2/c/%.obj: %.c always
	$(CC16) $(CC16FLAGS) -fo=$@ $<

$(BUILD_DIR)/boot/s2/s/%.obj: %.s always
	$(ASM) -f obj -o $@ $<

always: 
	mkdir -p $(BUILD_DIR)/boot/s2/c
	mkdir -p $(BUILD_DIR)/boot/s2/s

clean:
	rm -f $(BUILD_DIR)/boot/boots2.bin
	rm -f $(BUILD_DIR)/boot/s2/c/*
	rm -f $(BUILD_DIR)/boot/s2/s/*

