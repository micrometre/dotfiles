#!/bin/bash
####################################
#
# Quick VM Image Converter
# Simple conversion to VirtualBox/QEMU formats
#
####################################

check_dependencies() {
    local missing_deps=()
    
    command -v qemu-img >/dev/null 2>&1 || missing_deps+=("qemu-utils")
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo "ERROR: Missing required packages: ${missing_deps[*]}"
        echo "Install with: sudo apt install ${missing_deps[*]}"
        return 1
    fi
    
    return 0
}

show_usage() {
    echo "Usage: $0 <raw-image-file> [format]"
    echo ""
    echo "Formats:"
    echo "  vdi     - VirtualBox format"
    echo "  qcow2   - QEMU/KVM format (default)"
    echo "  vmdk    - VMware format"
    echo "  vhdx    - Hyper-V format"
    echo ""
    echo "Example:"
    echo "  $0 backup.img qcow2"
    echo "  $0 backup.img vdi"
}

convert_image() {
    local input_file="$1"
    local format="${2:-qcow2}"
    
    if [ ! -f "$input_file" ]; then
        echo "ERROR: Input file not found: $input_file"
        return 1
    fi
    
    local output_file="${input_file%.img}.${format}"
    
    echo "========================================="
    echo "Converting Disk Image"
    echo "========================================="
    echo "Input:  $input_file"
    echo "Output: $output_file"
    echo "Format: $format"
    echo "========================================="
    echo ""
    
    # Convert the image
    qemu-img convert -f raw -O "$format" -p "$input_file" "$output_file"
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "========================================="
        echo "Conversion Complete!"
        echo "========================================="
        echo "Output file: $output_file"
        echo "Size: $(du -h "$output_file" | cut -f1)"
        echo ""
        
        case $format in
            qcow2)
                echo "To use with QEMU/KVM:"
                echo "  qemu-system-x86_64 -m 2048 -hda $output_file"
                echo ""
                echo "To use with virt-manager:"
                echo "  1. Open virt-manager"
                echo "  2. Create new VM → Import existing disk image"
                echo "  3. Select: $output_file"
                ;;
            vdi)
                echo "To use with VirtualBox:"
                echo "  1. Open VirtualBox"
                echo "  2. Create new VM"
                echo "  3. Use existing hard disk: $output_file"
                echo ""
                echo "Or via command line:"
                echo "  VBoxManage createvm --name \"BackupTest\" --register"
                echo "  VBoxManage storagectl \"BackupTest\" --name \"SATA\" --add sata"
                echo "  VBoxManage storageattach \"BackupTest\" --storagectl \"SATA\" --port 0 --device 0 --type hdd --medium $output_file"
                ;;
            vmdk)
                echo "To use with VMware:"
                echo "  1. Open VMware"
                echo "  2. Create new VM"
                echo "  3. Use existing disk: $output_file"
                ;;
            vhdx)
                echo "To use with Hyper-V:"
                echo "  1. Open Hyper-V Manager"
                echo "  2. Create new VM"
                echo "  3. Use existing virtual hard disk: $output_file"
                ;;
        esac
        
        echo "========================================="
        return 0
    else
        echo "ERROR: Conversion failed"
        return 1
    fi
}

####################################
# Main Script
####################################

if ! check_dependencies; then
    exit 1
fi

if [ $# -lt 1 ]; then
    show_usage
    exit 1
fi

convert_image "$1" "$2"
exit $?
