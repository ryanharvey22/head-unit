CROSS   ?= aarch64-linux-gnu-
GCCVER  ?= -12
CC       = $(CROSS)gcc$(GCCVER)
LD       = $(CROSS)ld
OBJCOPY  = $(CROSS)objcopy
GNAT     = $(CROSS)gcc$(GCCVER)

ASFLAGS  = -ffreestanding -nostdlib
ADAFLAGS = -nostdlib -nostartfiles -O2 -gnatp

TARGET   = kernel8
OBJS     = boot.o main.o

all: $(TARGET).img

boot.o: boot.S
	$(CC) $(ASFLAGS) -c $< -o $@

main.o: main.adb
	$(GNAT) $(ADAFLAGS) -c $< -o $@

$(TARGET).elf: $(OBJS) linker.ld
	$(LD) -T linker.ld -o $@ $(OBJS)

$(TARGET).img: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@
	@echo "Built $@ ($$(wc -c < $@) bytes)"

clean:
	rm -f *.o *.ali $(TARGET).elf $(TARGET).img

.PHONY: all clean
