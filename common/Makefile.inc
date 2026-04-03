CROSS   ?= aarch64-linux-gnu-
GCCVER  ?= -12
CC       = $(CROSS)gcc$(GCCVER)
LD       = $(CROSS)ld
OBJCOPY  = $(CROSS)objcopy
GNAT     = $(CROSS)gcc$(GCCVER)

COMMON   = ../common
ASFLAGS  = -ffreestanding -nostdlib
ADAFLAGS = -nostdlib -nostartfiles -O2 -gnatp

TARGET   = kernel8

$(TARGET).img: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@
	@echo "Built $@ ($$(wc -c < $@) bytes)"

boot.o: $(COMMON)/boot.S
	$(CC) $(ASFLAGS) -c $< -o $@

clean:
	rm -f *.o *.ali $(TARGET).elf $(TARGET).img

.PHONY: all clean
