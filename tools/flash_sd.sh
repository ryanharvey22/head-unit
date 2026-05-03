#!/usr/bin/env bash
#
# flash_sd.sh — flash kernel8.img + config.txt to a Pi 4 SD card
#
# Usage:
#   ./tools/flash_sd.sh                       # auto-detect SD card mount
#   ./tools/flash_sd.sh /media/me/BOOT        # specify mount point
#
# Environment:
#   FETCH_FIRMWARE=1                          # also download Pi firmware
#                                             # files if they're missing
#   SKIP_BUILD=1                              # don't run `make` first
#   NO_UMOUNT=1                               # skip safe-eject at the end

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
KERNEL="$REPO_ROOT/build/kernel8.img"
CONFIG="$REPO_ROOT/common/config.txt"

PI_FIRMWARE_URL="https://github.com/raspberrypi/firmware/raw/master/boot"
FIRMWARE_FILES=(bootcode.bin start4.elf fixup4.dat bcm2711-rpi-4-b.dtb)

c_red()   { printf '\033[31m%s\033[0m' "$*"; }
c_green() { printf '\033[32m%s\033[0m' "$*"; }
c_dim()   { printf '\033[2m%s\033[0m'  "$*"; }
err()  { echo "$(c_red ERROR:) $*" >&2; exit 1; }
info() { echo "$(c_green '==>') $*"; }
hint() { echo "    $(c_dim "$*")"; }

# Prefer curl; fall back to wget (some minimal distros have no curl).
fetch_url() {
    local url="$1" out="$2"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL -o "$out" "$url"
    elif command -v wget >/dev/null 2>&1; then
        wget -q -O "$out" "$url"
    else
        err "Need curl or wget to download firmware (e.g. apt install curl)"
    fi
}

# ---------------------------------------------------------------------------
# 1. Build the kernel (unless told to skip)
# ---------------------------------------------------------------------------
if [ "${SKIP_BUILD:-0}" != "1" ]; then
    info "Building firmware"
    make -C "$REPO_ROOT" >/dev/null
fi

[ -f "$KERNEL" ] || err "Kernel not found: $KERNEL  (run 'make' first)"
[ -f "$CONFIG" ] || err "Config not found: $CONFIG"

# ---------------------------------------------------------------------------
# 2. Locate the SD card mount point
# ---------------------------------------------------------------------------
SD_PATH="${1:-}"

if [ -z "$SD_PATH" ]; then
    info "Auto-detecting SD card"
    candidates=()
    for base in "/media/$USER" "/run/media/$USER"; do
        [ -d "$base" ] || continue
        while IFS= read -r d; do
            candidates+=("$d")
        done < <(find "$base" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
    done

    if [ "${#candidates[@]}" -eq 0 ]; then
        err "No removable media mounted under /media/$USER or /run/media/$USER.
       Insert the SD card and let the desktop auto-mount it,
       or pass the path explicitly:  ./tools/flash_sd.sh /path/to/sd"
    fi

    if [ "${#candidates[@]}" -gt 1 ]; then
        echo "Multiple mount points found:"
        for c in "${candidates[@]}"; do echo "    $c"; done
        err "Pass the path explicitly:  ./tools/flash_sd.sh <path>"
    fi

    SD_PATH="${candidates[0]}"
fi

[ -d "$SD_PATH" ] || err "Not a directory: $SD_PATH"
[ -w "$SD_PATH" ] || err "Not writable: $SD_PATH (try sudo, or check the SD lock switch)"

info "SD card mount: $SD_PATH"

# Sanity-check: refuse to write to anything that's not removable / FAT.
# The mount path under /media or /run/media is already a strong signal,
# but double-check the parent directory.
case "$SD_PATH" in
    /media/*|/run/media/*) ;;
    *) err "Refusing to write to $SD_PATH — not under /media or /run/media.
       Remove this check at your own risk by editing flash_sd.sh."
    ;;
esac

# ---------------------------------------------------------------------------
# 3. Check / fetch Pi firmware files
# ---------------------------------------------------------------------------
missing=()
for f in "${FIRMWARE_FILES[@]}"; do
    [ -f "$SD_PATH/$f" ] || missing+=("$f")
done

if [ "${#missing[@]}" -gt 0 ]; then
    echo "Missing Pi firmware files on the SD card:"
    for f in "${missing[@]}"; do echo "    $f"; done

    if [ "${FETCH_FIRMWARE:-0}" = "1" ]; then
        info "Downloading firmware (FETCH_FIRMWARE=1)"
        for f in "${missing[@]}"; do
            url="$PI_FIRMWARE_URL/$f"
            echo "    $f"
            fetch_url "$url" "$SD_PATH/$f" || err "Failed to download $url"
        done
    else
        echo
        hint "Re-run with FETCH_FIRMWARE=1 to download them automatically:"
        hint "  FETCH_FIRMWARE=1 ./tools/flash_sd.sh $SD_PATH"
        hint "Or fetch manually (wget or curl):"
        for f in "${missing[@]}"; do
            hint "  wget -O \"$SD_PATH/$f\" \"$PI_FIRMWARE_URL/$f\""
        done
        exit 1
    fi
fi

# ---------------------------------------------------------------------------
# 4. Copy kernel + config
# ---------------------------------------------------------------------------
info "Copying kernel8.img ($(wc -c < "$KERNEL") bytes)"
cp "$KERNEL" "$SD_PATH/kernel8.img"

info "Copying config.txt"
cp "$CONFIG" "$SD_PATH/config.txt"

info "Syncing"
sync

# ---------------------------------------------------------------------------
# 5. Show what's on the card and unmount
# ---------------------------------------------------------------------------
echo
info "SD card contents:"
ls -la "$SD_PATH" | sed 's/^/    /'
echo

if [ "${NO_UMOUNT:-0}" != "1" ]; then
    info "Unmounting (safe to remove)"
    if udisksctl unmount -b "$(findmnt -no SOURCE "$SD_PATH")" 2>/dev/null; then
        :
    elif sudo umount "$SD_PATH" 2>/dev/null; then
        :
    else
        hint "Couldn't auto-unmount.  Run manually:  sudo umount '$SD_PATH'"
        exit 0
    fi
    echo "    Done.  Pull the card."
fi
