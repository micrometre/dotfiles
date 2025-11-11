#!/bin/bash
####################################
#
# Convert Backup to VM Disk Image
# Creates a bootable disk image from tar backup
#
####################################

# Configuration
SCRIPT_NAME="Backup to VM Image Converter"

####################################
# Functions
####################################

check_root() {
    if [ "$EUID" -ne 0 ]; then 
        echo "ERROR: This script must be run as root (use sudo)"
        exit 1
    fi
}

check_dependencies() {
    local missing_deps=()
    
    # Check for required tools
    command -v qemu-img >/dev/null 2>&1 || missing_deps+=("qemu-utils")
    command -v parted >/dev/null 2>&1 || missing_deps+=("parted")
    command -v mkfs.ext4 >/dev/null 2>&1 || missing_deps+=("e2fsprogs")
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo "ERROR: Missing required packages: ${missing_deps[*]}"
        echo "Install with: sudo apt install ${missing_deps[*]}"
        return 1
    fi
    
    return 0
}

list_backups() {
    echo "========================================="
    echo "Available Backup Files"
    echo "========================================="
    ls -lh /mnt/backup/*.tar.gz 2>/dev/null
    echo ""
}

create_vm_image() {
    local backup_file="$1"
    local image_size="$2"
    local output_dir="$3"
    
    if [ ! -f "$backup_file" ]; then
        echo "ERROR: Backup file not found: $backup_file"
        return 1
    fi
    
    # Generate output filename
    local backup_name=$(basename "$backup_file" .tar.gz)
    local image_file="$output_dir/${backup_name}.img"
    local mount_point="/mnt/vm-temp-$$"
    
    echo ""
    echo "========================================="
    echo "Creating VM Disk Image"
    echo "========================================="
    echo "Source: $backup_file"
    echo "Image: $image_file"
    echo "Size: ${image_size}GB"
    echo "========================================="
    echo ""
    
    # Step 1: Create raw disk image
    echo "[1/8] Creating disk image file..."
    dd if=/dev/zero of="$image_file" bs=1G count="$image_size" status=progress
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to create disk image"
        return 1
    fi
    
    # Step 2: Create partition table
    echo ""
    echo "[2/8] Creating partition table..."
    parted -s "$image_file" mklabel msdos
    parted -s "$image_file" mkpart primary ext4 1MiB 100%
    parted -s "$image_file" set 1 boot on
    
    # Step 3: Setup loop device
    echo ""
    echo "[3/8] Setting up loop device..."
    local loop_device=$(losetup -fP --show "$image_file")
    if [ -z "$loop_device" ]; then
        echo "ERROR: Failed to setup loop device"
        return 1
    fi
    echo "Loop device: $loop_device"
    
    # Wait for partition to appear
    sleep 2
    
    # Step 4: Create filesystem
    echo ""
    echo "[4/8] Creating ext4 filesystem..."
    mkfs.ext4 -F "${loop_device}p1"
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to create filesystem"
        losetup -d "$loop_device"
        return 1
    fi
    
    # Step 5: Mount the partition
    echo ""
    echo "[5/8] Mounting partition..."
    mkdir -p "$mount_point"
    mount "${loop_device}p1" "$mount_point"
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to mount partition"
        losetup -d "$loop_device"
        return 1
    fi
    
    # Step 6: Extract backup
    echo ""
    echo "[6/8] Extracting backup to image (this may take a while)..."
    # Note: tar removes leading '/' from paths, so we use -P to preserve them
    # or extract and handle the paths properly
    tar -xzpf "$backup_file" -C "$mount_point" --strip-components=0
    if [ $? -ne 0 ]; then
        echo "WARNING: Tar reported some errors, but continuing..."
    fi
    
    # Step 7: Create necessary directories and fix fstab
    echo ""
    echo "[7/8] Configuring system directories..."
    
    # Create essential directories if they don't exist
    mkdir -p "$mount_point"/{dev,proc,sys,run,tmp,mnt,media,lost+found}
    chmod 1777 "$mount_point/tmp"
    
    # Ensure boot directory structure exists
    mkdir -p "$mount_point/boot/grub"
    
    # Create a simple fstab
    cat > "$mount_point/etc/fstab" << EOF
# /etc/fstab: static file system information for VM
UUID=$(blkid -s UUID -o value "${loop_device}p1")  /               ext4    errors=remount-ro 0       1
EOF
    
    echo "Created fstab:"
    cat "$mount_point/etc/fstab"
    
    # Step 8: Install bootloader (GRUB)
    echo ""
    echo "[8/8] Installing GRUB bootloader..."
    
    # Check if grub is installed in the backup
    if [ ! -d "$mount_point/usr/lib/grub" ] && [ ! -d "$mount_point/usr/share/grub" ]; then
        echo "WARNING: GRUB not found in backup. Skipping bootloader installation."
        echo "You may need to install GRUB manually or use a live CD to make the image bootable."
    else
        # Mount necessary filesystems for chroot
        mount --bind /dev "$mount_point/dev"
        mount --bind /proc "$mount_point/proc"
        mount --bind /sys "$mount_point/sys"
        
        # Install GRUB (ignore errors if it fails)
        echo "Installing GRUB to $loop_device..."
        chroot "$mount_point" grub-install --target=i386-pc --boot-directory=/boot "$loop_device" 2>&1 || {
            echo "WARNING: GRUB installation had errors, but continuing..."
        }
        
        # Try to generate GRUB config
        if [ -f "$mount_point/usr/sbin/update-grub" ] || [ -f "$mount_point/usr/sbin/grub-mkconfig" ]; then
            chroot "$mount_point" update-grub 2>&1 || {
                echo "WARNING: GRUB config generation had errors, but continuing..."
            }
        fi
        
        # Cleanup chroot mounts
        umount "$mount_point/sys" 2>/dev/null
        umount "$mount_point/proc" 2>/dev/null
        umount "$mount_point/dev" 2>/dev/null
    fi
    
    # Step 9: Cleanup
    echo ""
    echo "Cleaning up..."
    sync
    umount "$mount_point"
    losetup -d "$loop_device"
    rmdir "$mount_point"
    
    echo ""
    echo "========================================="
    echo "VM Image Created Successfully!"
    echo "========================================="
    echo "Image file: $image_file"
    echo "Size: $(du -h "$image_file" | cut -f1)"
    echo ""
    echo "To use with VirtualBox:"
    echo "  VBoxManage convertfromraw $image_file ${image_file%.img}.vdi --format VDI"
    echo ""
    echo "To use with QEMU/KVM:"
    echo "  qemu-img convert -f raw -O qcow2 $image_file ${image_file%.img}.qcow2"
    echo "  qemu-system-x86_64 -m 2048 -hda ${image_file%.img}.qcow2"
    echo ""
    echo "To use raw image directly:"
    echo "  qemu-system-x86_64 -m 2048 -hda $image_file"
    echo "========================================="
    
    return 0
}

####################################
# Main Script
####################################

echo "========================================="
echo "$SCRIPT_NAME"
echo "========================================="
echo ""

check_root
if ! check_dependencies; then
    exit 1
fi

# Interactive mode
list_backups

echo "Enter the full path to the backup file:"
read -e backup_file

if [ ! -f "$backup_file" ]; then
    echo "ERROR: File not found: $backup_file"
    exit 1
fi

echo ""
echo "Enter disk image size in GB (recommended: 20-50):"
echo "Note: Should be larger than the extracted backup size"
read image_size

if ! [[ "$image_size" =~ ^[0-9]+$ ]] || [ "$image_size" -lt 10 ]; then
    echo "ERROR: Invalid size. Must be at least 10GB"
    exit 1
fi

echo ""
echo "Enter output directory for VM image (default: /mnt/backup):"
read -e output_dir
output_dir=${output_dir:-/mnt/backup}

if [ ! -d "$output_dir" ]; then
    echo "ERROR: Output directory does not exist: $output_dir"
    exit 1
fi

if [ ! -w "$output_dir" ]; then
    echo "ERROR: Output directory is not writable: $output_dir"
    exit 1
fi

echo ""
echo "========================================="
echo "Summary"
echo "========================================="
echo "Backup file: $backup_file"
echo "Image size: ${image_size}GB"
echo "Output directory: $output_dir"
echo ""
echo "This will take several minutes and requires ${image_size}GB of free space."
echo "========================================="
echo ""
read -p "Continue? (y/n): " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

# Create the VM image
create_vm_image "$backup_file" "$image_size" "$output_dir"

exit $?
