#!/bin/bash
####################################
#
# Restore from Backup Script
#
####################################

# Configuration
SCRIPT_NAME="System Restore from Backup"
BACKUP_DEST="/mnt/backup"

####################################
# Functions
####################################

check_root() {
    if [ "$EUID" -ne 0 ]; then 
        echo "ERROR: This script must be run as root (use sudo)"
        exit 1
    fi
}

check_destination() {
    if [ ! -d "$BACKUP_DEST" ]; then
        echo "ERROR: Backup directory $BACKUP_DEST does not exist"
        exit 1
    fi
}

list_backups() {
    echo "========================================="
    echo "Available Backup Files"
    echo "========================================="
    
    # List all tar.gz files with details
    ls -lh "$BACKUP_DEST"/*.tar.gz 2>/dev/null
    
    if [ $? -ne 0 ]; then
        echo "No backup files found in $BACKUP_DEST"
        return 1
    fi
    
    echo ""
    return 0
}

list_archive_contents() {
    local archive="$1"
    
    echo ""
    echo "========================================="
    echo "Contents of: $(basename "$archive")"
    echo "========================================="
    
    tar -tzvf "$archive" | head -50
    
    echo ""
    echo "(Showing first 50 files. Total files: $(tar -tzf "$archive" | wc -l))"
    echo ""
}

restore_file() {
    local archive="$1"
    local file_path="$2"
    local restore_to="$3"
    
    echo "Extracting $file_path to $restore_to..."
    
    # Create destination directory if it doesn't exist
    mkdir -p "$restore_to"
    
    # Remove leading slash from file path for tar
    file_path_clean="${file_path#/}"
    
    tar -xzvf "$archive" -C "$restore_to" "$file_path_clean"
    
    if [ $? -eq 0 ]; then
        echo "File restored successfully to: $restore_to/$file_path_clean"
        return 0
    else
        echo "ERROR: Failed to restore file"
        return 1
    fi
}

restore_full() {
    local archive="$1"
    
    echo ""
    echo "========================================="
    echo "WARNING: FULL SYSTEM RESTORE"
    echo "========================================="
    echo "This will restore ALL files from the backup."
    echo "This will OVERWRITE existing files on your system!"
    echo ""
    echo "Archive: $archive"
    echo ""
    read -p "Are you ABSOLUTELY sure you want to proceed? (type 'YES' to confirm): " confirm
    
    if [ "$confirm" != "YES" ]; then
        echo "Restore cancelled."
        return 1
    fi
    
    echo ""
    echo "Starting full system restore..."
    echo "This may take a while..."
    echo ""
    
    cd /
    tar -xzvf "$archive"
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "========================================="
        echo "Full system restore completed successfully!"
        echo "You may need to reboot your system."
        echo "========================================="
        return 0
    else
        echo ""
        echo "========================================="
        echo "ERROR: Restore failed!"
        echo "========================================="
        return 1
    fi
}

interactive_restore() {
    list_backups
    
    if [ $? -ne 0 ]; then
        exit 1
    fi
    
    echo "Enter the full path to the backup file:"
    read -e backup_file
    
    if [ ! -f "$backup_file" ]; then
        echo "ERROR: File not found: $backup_file"
        exit 1
    fi
    
    echo ""
    echo "Select restore option:"
    echo "1) List archive contents"
    echo "2) Restore specific file(s)"
    echo "3) Full system restore (DANGEROUS!)"
    echo "4) Exit"
    echo ""
    read -p "Enter choice (1-4): " choice
    
    case $choice in
        1)
            list_archive_contents "$backup_file"
            ;;
        2)
            echo ""
            echo "Enter the path of the file to restore (e.g., /etc/fstab):"
            read file_to_restore
            
            echo "Enter destination directory (e.g., /tmp for testing, or / for live restore):"
            read restore_dest
            
            restore_file "$backup_file" "$file_to_restore" "$restore_dest"
            ;;
        3)
            restore_full "$backup_file"
            ;;
        4)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice"
            exit 1
            ;;
    esac
}

####################################
# Main Script
####################################

echo "========================================="
echo "$SCRIPT_NAME"
echo "========================================="
echo ""

check_root
check_destination

# Check for command line arguments
if [ $# -eq 0 ]; then
    # Interactive mode
    interactive_restore
else
    # Command line mode
    case "$1" in
        --list)
            list_backups
            ;;
        --contents)
            if [ -z "$2" ]; then
                echo "ERROR: Please specify backup file"
                echo "Usage: $0 --contents <backup-file>"
                exit 1
            fi
            list_archive_contents "$2"
            ;;
        --restore-file)
            if [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
                echo "ERROR: Missing arguments"
                echo "Usage: $0 --restore-file <backup-file> <file-path> <destination>"
                exit 1
            fi
            restore_file "$2" "$3" "$4"
            ;;
        --restore-full)
            if [ -z "$2" ]; then
                echo "ERROR: Please specify backup file"
                echo "Usage: $0 --restore-full <backup-file>"
                exit 1
            fi
            restore_full "$2"
            ;;
        *)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  (no options)                                   Interactive mode"
            echo "  --list                                         List available backups"
            echo "  --contents <backup-file>                       List contents of backup"
            echo "  --restore-file <backup> <file> <destination>   Restore specific file"
            echo "  --restore-full <backup-file>                   Full system restore"
            exit 1
            ;;
    esac
fi
