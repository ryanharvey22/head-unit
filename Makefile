CROSS   ?= aarch64-none-elf-
CC       = $(CROSS)gcc
LD       = $(CROSS)ld
OBJCOPY  = $(CROSS)objcopy

ASFLAGS = -ffreestanding -nostdlib
TARGET  = kernel8

all: $(TARGET).img

boot.o: boot.S
	$(CC) $(ASFLAGS) -c $< -o $@

$(TARGET).elf: boot.o linker.ld
	$(LD) -T linker.ld -o $@ boot.o

$(TARGET).img: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@
	@echo "Built $@ ($$(wc -c < $@) bytes)"

clean:
	rm -f *.o $(TARGET).elf $(TARGET).img

.PHONY: all clean
