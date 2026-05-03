#  head-unit Makefile — Raspberry Pi 4 bare-metal firmware only
#
#  Usage:
#    make                  Build build/kernel8.img
#    make clean            Remove build/
#    make distclean        Same as clean (single output tree)
#    make flash            Build and copy kernel8.img + config.txt to SD card
#

BUILD_DIR := build
SRC_DIR   := src
COMMON    := common

CROSS    := aarch64-linux-gnu-
GCCVER   := -12
GNAT     := $(CROSS)gcc$(GCCVER)
CC       := $(CROSS)gcc$(GCCVER)
LD       := $(CROSS)ld
OBJCOPY  := $(CROSS)objcopy

ADAFLAGS := -nostdlib -nostartfiles -O2 -gnatp -gnat2012
ASFLAGS  := -ffreestanding -nostdlib
CFLAGS   := -ffreestanding -nostdlib -nostartfiles -O2 -fno-builtin
INCLUDES := -I$(SRC_DIR)

ADA_OBJS := \
   $(BUILD_DIR)/mailbox.o \
   $(BUILD_DIR)/hal-gpio.o \
   $(BUILD_DIR)/hal-uart.o \
   $(BUILD_DIR)/hal-display.o \
   $(BUILD_DIR)/hal-clock.o \
   $(BUILD_DIR)/head_unit_main.o \
   $(BUILD_DIR)/main.o

OBJS := $(BUILD_DIR)/boot.o $(BUILD_DIR)/runtime.o $(ADA_OBJS)

.PHONY: all clean distclean flash

all: $(BUILD_DIR)/kernel8.img

$(BUILD_DIR):
	@mkdir -p $@

$(BUILD_DIR)/boot.o: $(COMMON)/boot.S | $(BUILD_DIR)
	$(CC) $(ASFLAGS) -c $< -o $@

$(BUILD_DIR)/runtime.o: $(COMMON)/runtime.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

vpath %.adb $(SRC_DIR)
vpath %.ads $(SRC_DIR)

$(BUILD_DIR)/%.o: %.adb | $(BUILD_DIR)
	$(GNAT) $(ADAFLAGS) $(INCLUDES) -c $< -o $@

$(BUILD_DIR)/kernel8.elf: $(OBJS) $(COMMON)/linker.ld
	$(LD) -T $(COMMON)/linker.ld -o $@ $(OBJS)

$(BUILD_DIR)/kernel8.img: $(BUILD_DIR)/kernel8.elf
	$(OBJCOPY) -O binary $< $@
	@echo "Built $@ ($$(wc -c < $@) bytes)"

clean:
	rm -rf $(BUILD_DIR)

distclean:
	rm -rf $(BUILD_DIR)

flash:
	tools/flash_sd.sh
