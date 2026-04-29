#!/bin/bash
#  run.sh — Launch the bare-metal kernel in QEMU
#
#  QEMU 7.2+ has the raspi4b machine type.  Older versions had raspi3b
#  but that's a different SoC.  Install with:  sudo apt install qemu-system-arm

set -e

KERNEL="${1:-build/qemu/kernel8.img}"

if [ ! -f "$KERNEL" ]; then
    echo "Kernel not found: $KERNEL"
    echo "Build with: make TARGET=qemu"
    exit 1
fi

if ! command -v qemu-system-aarch64 >/dev/null 2>&1; then
    echo "qemu-system-aarch64 not installed."
    echo "Install with: sudo apt install qemu-system-arm"
    exit 1
fi

# Check whether raspi4b is supported
if ! qemu-system-aarch64 -machine help 2>/dev/null | grep -q raspi4b; then
    echo "Your QEMU version does not support raspi4b machine type."
    echo "You need QEMU 7.2 or later.  Falling back to raspi3b for testing."
    MACHINE="raspi3b"
else
    MACHINE="raspi4b"
fi

echo "Launching QEMU ($MACHINE) with $KERNEL"
echo "Serial output below.  Ctrl-A then X to exit."
echo "------------------------------------------------------------"

exec qemu-system-aarch64 \
    -machine "$MACHINE" \
    -kernel "$KERNEL" \
    -serial stdio \
    -display none \
    -no-reboot
