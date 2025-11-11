#!/bin/bash
####################################
#
# Simple Backup to Raw Disk (Non-bootable)
# For mounting and testing backup contents in VM
# Does not install bootloader
#
####################################

SCRIPT_NAME="Backup to Raw Disk (Data Only)"

check_root() {
    if [ "$EUID" -ne 0 ]; then 
        echo "ERROR: This script must be run as root (use sudo)"
        exit 1
    fi
}

echo "========================================="
echo "$SCRIPT_NAME"
echo "========================================="
echo ""
echo "This creates a data-only disk image that can be"
echo "attached to a VM as a secondary disk for testing."
echo "(Not bootable, but simpler and more reliable)"
echo "========================================="
echo ""

check_root

# List available backups
echo "Available backups:"
ls -lh /mnt/backup/*.tar.gz 2>/dev/null
echo ""

read -e -p "Enter backup file path: " backup_file
if [ ! -f "$backup_file" ]; then
    echo "ERROR: File not found"
    exit 1
fi

read -p "Enter disk size in GB (e.g., 30): " size
if ! [[ "$size" =~ ^[0-9]+$ ]]; then
    echo "ERROR: Invalid size"
    exit 1
fi

read -e -p "Output directory [/mnt/backup]: " output_dir
output_dir=${output_dir:-/mnt/backup}

backup_name=$(basename "$backup_file" .tar.gz)
image_file="$output_dir/${backup_name}-data.img"
mount_point="/mnt/vm-temp-$$"

echo ""
echo "Creating: $image_file"
echo "Size: ${size}GB"
echo ""
read -p "Continue? (y/n): " -n 1 -r
echo
[[ ! $REPLY =~ ^[Yy]$ ]] && exit 0

echo ""
echo "[1/5] Creating ${size}GB disk image..."
dd if=/dev/zero of="$image_file" bs=1G count="$size" status=progress

echo ""
echo "[2/5] Creating filesystem..."
mkfs.ext4 -F "$image_file"

echo ""
echo "[3/5] Mounting image..."
mkdir -p "$mount_point"
mount -o loop "$image_file" "$mount_point"

echo ""
echo "[4/5] Extracting backup (this may take a while)..."
tar -xzpf "$backup_file" -C "$mount_point" 2>&1 | head -20

echo ""
echo "[5/5] Cleaning up..."
sync
umount "$mount_point"
rmdir "$mount_point"

echo ""
echo "========================================="
echo "Success!"
echo "========================================="
echo "Data disk image: $image_file"
echo "Size: $(du -h "$image_file" | cut -f1)"
echo ""
echo "To use with QEMU as secondary disk:"
echo "  qemu-system-x86_64 -m 2048 -hda main.qcow2 -hdb $image_file"
echo ""
echo "To mount and inspect contents:"
echo "  sudo mkdir -p /mnt/test"
echo "  sudo mount -o loop $image_file /mnt/test"
echo "  ls /mnt/test"
echo "  sudo umount /mnt/test"
echo ""
echo "To convert to other formats:"
echo "  ./quick-vm-convert.sh $image_file qcow2"
echo "========================================="
