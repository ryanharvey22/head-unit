include ../common/Makefile.inc

UART_DIR = ../uart

OBJS = boot.o uart.o fixed_point.o sin_table.o fft.o main.o

all: $(TARGET).img

uart.o: $(UART_DIR)/uart.adb $(UART_DIR)/uart.ads
	$(GNAT) $(ADAFLAGS) -I$(UART_DIR) -c $(UART_DIR)/uart.adb -o $@

fixed_point.o: fixed_point.adb fixed_point.ads
	$(GNAT) $(ADAFLAGS) -c fixed_point.adb -o $@

sin_table.o: sin_table.ads
	@echo "TODO: sin_table.adb not yet written"
	@false

fft.o: fft.adb fft.ads
	$(GNAT) $(ADAFLAGS) -c fft.adb -o $@

main.o: main.adb
	$(GNAT) $(ADAFLAGS) -I. -I$(UART_DIR) -c $< -o $@

$(TARGET).elf: $(OBJS) $(COMMON)/linker.ld
	$(LD) -T $(COMMON)/linker.ld -o $@ $(OBJS)
