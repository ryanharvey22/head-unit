include ../common/Makefile.inc

OBJS = boot.o uart.o main.o

all: $(TARGET).img

uart.o: uart.adb uart.ads
	$(GNAT) $(ADAFLAGS) -c uart.adb -o $@

main.o: main.adb
	$(GNAT) $(ADAFLAGS) -I. -c $< -o $@

$(TARGET).elf: $(OBJS) $(COMMON)/linker.ld
	$(LD) -T $(COMMON)/linker.ld -o $@ $(OBJS)
