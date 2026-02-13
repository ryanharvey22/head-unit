# Bare metal Raspberry Pi 4 – Hello World
# Requires: aarch64-none-elf-gcc, aarch64-none-elf-ld (ARM GNU Toolchain)

PREFIX  ?= aarch64-none-elf-
CC      = $(PREFIX)gcc
LD      = $(PREFIX)ld
OBJCOPY = $(PREFIX)objcopy

CFLAGS  = -Wall -Wextra -O2 -ffreestanding -nostdlib -nostartfiles
LDFLAGS = -T linker.ld

OBJS    = boot.o main.o
TARGET  = kernel8.img

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(OBJS)
	$(LD) $(LDFLAGS) -o kernel8.elf $(OBJS)
	$(OBJCOPY) kernel8.elf -O binary $(TARGET)

%.o: %.S
	$(CC) $(CFLAGS) -c -o $@ $<

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f $(OBJS) kernel8.elf $(TARGET)
