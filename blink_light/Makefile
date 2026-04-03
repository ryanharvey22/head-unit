include ../common/Makefile.inc

OBJS = boot.o main.o

all: $(TARGET).img

main.o: main.adb
	$(GNAT) $(ADAFLAGS) -c $< -o $@

$(TARGET).elf: $(OBJS) $(COMMON)/linker.ld
	$(LD) -T $(COMMON)/linker.ld -o $@ $(OBJS)
