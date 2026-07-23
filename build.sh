#!/usr/bin/env bash
### Debola Live ISO Builder
### Builds a live + installable Debian Trixie ISO with Openbox desktop
###
### Usage:
###   sudo ./build.sh              # Full build
###   sudo ./build.sh --clean      # Clean build artifacts only
###   sudo ./build.sh --help       # Show help
###

set -euo pipefail

DEBOLA_DIR="$(cd "$(dirname "$0")" && pwd)"
DEBOLA_ASSETS="${DEBOLA_DIR}/../debola"

DISTRICT="trixie"
ARCH="amd64"
LIVE_USER="debola"
ISO_NAME="debola-live"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "${GREEN}[$(date '+%H:%M:%S')]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
die()  { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }

usage() {
    cat << EOF
Debola Live ISO Builder

Usage: $(basename "$0") [OPTIONS]

Options:
  --clean       Clean build artifacts and start fresh
  --assets DIR  Path to debola assets repo (default: ../debola)
  --help        Show this help

Output:
  debolaD/output/debola-live-trixie-YYYYMMDD.iso

Prerequisites:
  A Debian-based host (amd64) with sudo. The script installs
  missing build dependencies automatically.
EOF
    exit 0
}

CLEAN=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --clean)    CLEAN=true; shift ;;
        --assets)   DEBOLA_ASSETS="$2"; shift 2 ;;
        --help|-h)  usage ;;
        *)          die "Unknown option: $1" ;;
    esac
done

echo ""
echo "========================================"
echo "  DEBOLA LIVE ISO BUILDER"
echo "========================================"
echo ""

# ── Check root ───────────────────────────────────────────────
[[ $EUID -ne 0 ]] && die "Must be run as root: sudo ./build.sh"

# ── Check dependencies ───────────────────────────────────────
log "Checking build dependencies..."
LB_DEPS="dctrl-tools live-build debootstrap isolinux loadlin grub-efi-amd64-bin grub-efi-ia32-bin librsvg2-bin appstream syslinux-common xorriso mtools"
MISSING=""
for dep in $LB_DEPS; do
    if ! dpkg -s "$dep" &>/dev/null; then
        MISSING="$MISSING $dep"
    fi
done
if [[ -n "$MISSING" ]]; then
    log "Installing missing dependencies:$MISSING"
    apt-get update -qq && apt-get install -y -qq $MISSING
fi
log "Dependencies OK."

# ── Clean if requested ──────────────────────────────────────
if $CLEAN; then
    log "Cleaning build artifacts..."
    cd "$DEBOLA_DIR"
    for mnt in chroot/sys chroot/proc chroot/dev/pts chroot/dev/shm chroot/dev chroot/run; do
        umount -l "$DEBOLA_DIR/$mnt" 2>/dev/null || true
    done
    lb clean --purge 2>/dev/null || true
    rm -rf chroot chroot.tmp cache binary .build *.stage *.iso *.log
    rm -rf output/*.iso 2>/dev/null || true
    log "Clean complete."
fi

# ── Sync debola assets into skel ─────────────────────────────
log "Syncing debola assets into build tree..."

SKEL="$DEBOLA_DIR/config/includes.chroot/etc/skel"
mkdir -p "$SKEL" "$SKEL/.config"

if [[ ! -d "$DEBOLA_ASSETS" ]]; then
    die "Debola assets not found at $DEBOLA_ASSETS
Set --assets DIR or run from parent of debola/"
fi

# Home dotfiles
if [[ -d "$DEBOLA_ASSETS/home" ]]; then
    cp -r "$DEBOLA_ASSETS/home/."* "$SKEL/" 2>/dev/null || true
    cp -r "$DEBOLA_ASSETS/home/"* "$SKEL/" 2>/dev/null || true
    log "  Home files synced."
fi

# Config files
if [[ -d "$DEBOLA_ASSETS/config" ]]; then
    cp -r "$DEBOLA_ASSETS/config/"* "$SKEL/.config/" 2>/dev/null || true
    log "  Config files synced."
fi

# Bin scripts
if [[ -d "$DEBOLA_ASSETS/bin" ]]; then
    mkdir -p "$SKEL/bin"
    cp -r "$DEBOLA_ASSETS/bin/"* "$SKEL/bin/"
    chmod +x "$SKEL/bin/"* 2>/dev/null || true
    log "  Bin scripts synced."
fi

# Local share (themes, etc.)
if [[ -d "$DEBOLA_ASSETS/local/share" ]]; then
    mkdir -p "$SKEL/.local/share"
    cp -r "$DEBOLA_ASSETS/local/share/"* "$SKEL/.local/share/"
    log "  Local share synced."
fi

# Wallpapers
if [[ -d "$DEBOLA_ASSETS/Pictures/backgrounds" ]]; then
    mkdir -p "$SKEL/Pictures/backgrounds/"
    cp "$DEBOLA_ASSETS/Pictures/backgrounds/"* "$SKEL/Pictures/backgrounds/" 2>/dev/null || true
    log "  Wallpapers synced."
fi

# Other Pictures
if [[ -d "$DEBOLA_ASSETS/Pictures" ]]; then
    mkdir -p "$SKEL/Pictures/"
    find "$DEBOLA_ASSETS/Pictures" -maxdepth 1 -type f -exec cp {} "$SKEL/Pictures/" \; 2>/dev/null || true
    log "  Pictures synced."
fi

# XDG directories
mkdir -p "$SKEL"/{Documents,Downloads,Music,Pictures,Videos,Desktop}

# Fix $USER tokens in config files
log "Fixing \$USER tokens in configs..."
find "$SKEL" -type f \( \
    -name "*.cfg" -o -name "config" -o -name "*.xml" \
    -o -name "bookmarks" -o -name "uca.xml" -o -name "frank" \) 2>/dev/null | while read -r f; do
    sed -i "s|\\\$USER|$LIVE_USER|g" "$f" 2>/dev/null || true
done

# Fix wallpapers.cfg paths
if [[ -f "$SKEL/.config/wallpapers.cfg" ]]; then
    sed -i "s|/home/\\\$USER/Pictures/backgrounds|/usr/share/backgrounds/debola|g" \
        "$SKEL/.config/wallpapers.cfg" 2>/dev/null || true
fi

log "Assets synced."

# ── Prepare build environment ────────────────────────────────
cd "$DEBOLA_DIR"

# Force-unmount stale mounts
for mnt in chroot/sys chroot/proc chroot/dev/pts chroot/dev/shm chroot/dev chroot/run; do
    umount -l "$DEBOLA_DIR/$mnt" 2>/dev/null || true
done

echo ""
log "Configuring live-build..."

# ── lb config ────────────────────────────────────────────────
lb config noauto \
    --architecture "$ARCH" \
    --distribution "$DISTRICT" \
    --archive-areas "main contrib non-free non-free-firmware" \
    --binary-images iso-hybrid \
    --bootloaders "syslinux grub-efi" \
    --memtest none \
    --apt-recommends false \
    --firmware-chroot false \
    --bootappend-live "boot=live components username=$LIVE_USER hostname=debola autologin quiet splash" \
    --iso-application "Debola Live" \
    --iso-publisher "Debola Project" \
    --iso-volume "Debola $DISTRICT"

# Fix ownership (lb config creates as root)
chown -R "$(id -u):$(id -g)" config/ 2>/dev/null || true

# Override cache settings - the automatic bootstrap cache save fails because
# debootstrap mounts /sys inside the chroot and cp -a can't copy sysfs.
# We create cache/bootstrap manually after lb bootstrap instead.
sed -i 's/LB_CACHE="false"/LB_CACHE="true"/' config/common
sed -i 's/LB_CACHE_STAGES="bootstrap"/LB_CACHE_STAGES="none"/' config/common
sed -i 's/LB_CACHE_PACKAGES="true"/LB_CACHE_PACKAGES="false"/' config/common

echo ""
log "Building ISO (this will take a while)..."

# ── Stage 1: Bootstrap ───────────────────────────────────────
log "Stage 1: Bootstrap..."
lb bootstrap 2>&1 | tee build.log

# Create bootstrap cache manually (workaround for debootstrap/sysfs issue)
log "Creating bootstrap cache..."
for mnt in chroot/sys/firmware/efi/efivars chroot/sys chroot/proc chroot/dev/pts chroot/dev/shm chroot/dev chroot/run; do
    umount -l "$DEBOLA_DIR/$mnt" 2>/dev/null || true
done
mkdir -p cache
rsync -ax --delete chroot/ cache/bootstrap/
log "Bootstrap cache created."

# ── Stage 2: Chroot ─────────────────────────────────────────
log "Stage 2: Chroot..."
lb chroot 2>&1 | tee -a build.log

# ── Stage 3: Binary ─────────────────────────────────────────
log "Stage 3: Binary..."
lb binary 2>&1 | tee -a build.log

# ── Locate output ────────────────────────────────────────────
mkdir -p output
ISO_FILE=$(find . -maxdepth 1 -name "*.iso" -print -quit 2>/dev/null || true)

if [[ -z "$ISO_FILE" ]] || [[ ! -f "$ISO_FILE" ]]; then
    die "ISO build failed. Check build.log for details."
fi

FINAL_NAME="${ISO_NAME}-${DISTRICT}-$(date +%Y%m%d).iso"
mv "$ISO_FILE" "output/$FINAL_NAME"

echo ""
echo "========================================"
echo "  BUILD COMPLETE"
echo "========================================"
echo ""
echo "  ISO: output/$FINAL_NAME"
echo "  Size: $(du -h "output/$FINAL_NAME" | cut -f1)"
echo ""
echo "  Write to USB:"
echo "    sudo dd if=output/$FINAL_NAME of=/dev/sdX bs=4M status=progress"
echo ""
