CROSS   ?= aarch64-none-elf-
CC       = $(CROSS)gcc
LD       = $(CROSS)ld
OBJCOPY  = $(CROSS)objcopy

CFLAGS  = -ffreestanding -nostdlib -nostartfiles -Wall -Wextra -O2
ASFLAGS = -ffreestanding -nostdlib

TARGET  = kernel8
OBJS    = boot.o mailbox.o main.o

all: $(TARGET).img

boot.o: boot.S
	$(CC) $(ASFLAGS) -c $< -o $@

mailbox.o: mailbox.c mailbox.h
	$(CC) $(CFLAGS) -c $< -o $@

main.o: main.c mailbox.h
	$(CC) $(CFLAGS) -c $< -o $@

$(TARGET).elf: $(OBJS) linker.ld
	$(LD) -T linker.ld -o $@ $(OBJS)

$(TARGET).img: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@
	@echo "Built $@ ($$(wc -c < $@) bytes)"

clean:
	rm -f $(OBJS) $(TARGET).elf $(TARGET).img

.PHONY: all clean
