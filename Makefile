#  head-unit Makefile
#
#  Usage:
#    make                      Build for QEMU (default — fast dev loop)
#    make TARGET=qemu          Same as above
#    make TARGET=pi            Build kernel8.img for real Raspberry Pi 4 SD card
#    make run                  Build + boot in QEMU (UART output to terminal)
#    make test                 Build + run native unit tests for protocol packages
#    make clean                Clean current target
#    make distclean            Clean all targets

TARGET ?= qemu

ifeq ($(TARGET),pi)
   HAL_BODY_DIR := hal_pi
   EXTRA_OBJS   := build/$(TARGET)/mailbox.o
else ifeq ($(TARGET),qemu)
   HAL_BODY_DIR := hal_qemu
   EXTRA_OBJS   :=
else
   $(error Unknown TARGET '$(TARGET)'.  Use 'pi' or 'qemu'.)
endif

BUILD_DIR := build/$(TARGET)
HAL_SRC   := hal
UI_SRC    := ui
APP_SRC   := app
NMEA_SRC  := nmea
OBD2_SRC  := obd2
COMMON    := common

# ---------------------------------------------------------------------------
# Bare-metal cross toolchain
# ---------------------------------------------------------------------------
CROSS    := aarch64-linux-gnu-
GCCVER   := -12
GNAT     := $(CROSS)gcc$(GCCVER)
CC       := $(CROSS)gcc$(GCCVER)
LD       := $(CROSS)ld
OBJCOPY  := $(CROSS)objcopy

ADAFLAGS := -nostdlib -nostartfiles -O2 -gnatp -gnat2012
ASFLAGS  := -ffreestanding -nostdlib
CFLAGS   := -ffreestanding -nostdlib -nostartfiles -O2 -fno-builtin
INCLUDES := -I$(HAL_SRC) -I$(HAL_BODY_DIR) -I$(UI_SRC) -I$(APP_SRC) \
            -I$(NMEA_SRC) -I$(OBD2_SRC)

# ---------------------------------------------------------------------------
# Bare-metal object list
# ---------------------------------------------------------------------------
ADA_OBJS := \
   $(BUILD_DIR)/hal-uart.o \
   $(BUILD_DIR)/hal-display.o \
   $(BUILD_DIR)/hal-input.o \
   $(BUILD_DIR)/hal-gps.o \
   $(BUILD_DIR)/hal-canbus.o \
   $(BUILD_DIR)/hal-audio.o \
   $(BUILD_DIR)/hal-clock.o \
   $(BUILD_DIR)/nmea-parser.o \
   $(BUILD_DIR)/obd2-decoder.o \
   $(BUILD_DIR)/ui-widgets.o \
   $(BUILD_DIR)/ui-screen.o \
   $(BUILD_DIR)/ui-pages-home.o \
   $(BUILD_DIR)/head_unit_main.o \
   $(BUILD_DIR)/main.o

OBJS := $(BUILD_DIR)/boot.o $(BUILD_DIR)/runtime.o $(EXTRA_OBJS) $(ADA_OBJS)

# ---------------------------------------------------------------------------
# Build rules
# ---------------------------------------------------------------------------
.PHONY: all clean distclean run test

all: $(BUILD_DIR)/kernel8.img

$(BUILD_DIR):
	@mkdir -p $@

$(BUILD_DIR)/boot.o: $(COMMON)/boot.S | $(BUILD_DIR)
	$(CC) $(ASFLAGS) -c $< -o $@

$(BUILD_DIR)/runtime.o: $(COMMON)/runtime.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

# Find Ada sources/specs in any of the source dirs
vpath %.adb $(HAL_BODY_DIR) $(UI_SRC) $(APP_SRC) $(NMEA_SRC) $(OBD2_SRC)
vpath %.ads $(HAL_SRC) $(UI_SRC) $(APP_SRC) $(HAL_BODY_DIR) $(NMEA_SRC) $(OBD2_SRC)

$(BUILD_DIR)/%.o: %.adb | $(BUILD_DIR)
	$(GNAT) $(ADAFLAGS) $(INCLUDES) -c $< -o $@

ifeq ($(TARGET),pi)
$(BUILD_DIR)/mailbox.o: hal_pi/mailbox.adb hal_pi/mailbox.ads | $(BUILD_DIR)
	$(GNAT) $(ADAFLAGS) $(INCLUDES) -c hal_pi/mailbox.adb -o $@
endif

$(BUILD_DIR)/kernel8.elf: $(OBJS) $(COMMON)/linker.ld
	$(LD) -T $(COMMON)/linker.ld -o $@ $(OBJS)

$(BUILD_DIR)/kernel8.img: $(BUILD_DIR)/kernel8.elf
	$(OBJCOPY) -O binary $< $@
	@echo "Built $@ ($$(wc -c < $@) bytes)"

# ---------------------------------------------------------------------------
# Native unit tests (host laptop, no Pi/QEMU involvement)
# ---------------------------------------------------------------------------
TEST_BUILD     := build/tests
HOST_GNATMAKE  := gnatmake-12
TEST_FLAGS     := -O0 -g -gnata -gnat2012

TESTS := $(TEST_BUILD)/test_nmea $(TEST_BUILD)/test_obd2

$(TEST_BUILD):
	@mkdir -p $@

# Run gnatmake from inside the build dir so that the binder-generated
# b~*.adb files don't clutter the repo root.
$(TEST_BUILD)/test_nmea: tests/test_nmea.adb $(NMEA_SRC)/nmea.ads \
                         $(NMEA_SRC)/nmea-parser.ads $(NMEA_SRC)/nmea-parser.adb \
                         | $(TEST_BUILD)
	cd $(TEST_BUILD) && $(HOST_GNATMAKE) $(TEST_FLAGS) \
	   -aI../../$(NMEA_SRC) -aI../../tests \
	   -o test_nmea ../../tests/test_nmea.adb

$(TEST_BUILD)/test_obd2: tests/test_obd2.adb $(OBD2_SRC)/obd2.ads \
                         $(OBD2_SRC)/obd2-decoder.ads $(OBD2_SRC)/obd2-decoder.adb \
                         | $(TEST_BUILD)
	cd $(TEST_BUILD) && $(HOST_GNATMAKE) $(TEST_FLAGS) \
	   -aI../../$(OBD2_SRC) -aI../../tests \
	   -o test_obd2 ../../tests/test_obd2.adb

test: $(TESTS)
	@echo "================================================================"
	@for t in $(TESTS); do \
	   echo "Running $$t"; \
	   $$t || exit 1; \
	   echo ""; \
	done
	@echo "================================================================"
	@echo "All host unit tests PASSED."

# ---------------------------------------------------------------------------
# House keeping
# ---------------------------------------------------------------------------
clean:
	rm -rf $(BUILD_DIR)

distclean:
	rm -rf build

run: all
ifeq ($(TARGET),qemu)
	tools/qemu/run.sh $(BUILD_DIR)/kernel8.img
else
	@echo "'make run' only works for TARGET=qemu.  Flash $(BUILD_DIR)/kernel8.img to SD card for pi target."
endif
