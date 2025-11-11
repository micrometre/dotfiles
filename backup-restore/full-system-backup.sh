#!/bin/bash
####################################
#
# Full System Backup Script
# Based on Ubuntu documentation
#
####################################

# Configuration
SCRIPT_NAME="Full System Backup"
BACKUP_DATE=$(date +%Y-%m-%d_%H-%M-%S)
HOSTNAME=$(hostname -s)
DAY=$(date +%A)

# What to backup - Based on actual system directories
# Note: /snap contains snaps (5.1G), /boot has kernel images (254M)
# /srv is typically for service data (currently empty)
BACKUP_DIRS="/home /etc /var /root /boot /opt /usr/local /srv"

# Directories to exclude (to reduce backup size and avoid issues)
EXCLUDE_DIRS=(
    "/var/cache"
    "/var/tmp"
    "/var/log"
    "/var/backups"
    "/home/*/.cache"
    "/home/*/.local/share/Trash"
    "/var/lib/docker"
    "/var/snap"
)

# Where to backup to (change this to your backup location)
# This could be an external drive, NFS mount, or other location
BACKUP_DEST="/mnt/backup"

# Archive filename
ARCHIVE_FILE="$HOSTNAME-$DAY-$BACKUP_DATE.tar.gz"

# Log file
LOG_FILE="$BACKUP_DEST/backup-$BACKUP_DATE.log"

####################################
# Functions
####################################

# Check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then 
        echo "ERROR: This script must be run as root (use sudo)"
        exit 1
    fi
}

# Check if backup destination exists
check_destination() {
    if [ ! -d "$BACKUP_DEST" ]; then
        echo "ERROR: Backup destination $BACKUP_DEST does not exist"
        echo "Please create it or mount your backup drive first"
        exit 1
    fi
    
    # Check if destination is writable
    if [ ! -w "$BACKUP_DEST" ]; then
        echo "ERROR: Backup destination $BACKUP_DEST is not writable"
        exit 1
    fi
}

# Build exclude arguments for tar
build_exclude_args() {
    EXCLUDE_ARGS=""
    for dir in "${EXCLUDE_DIRS[@]}"; do
        EXCLUDE_ARGS="$EXCLUDE_ARGS --exclude=$dir"
    done
}

# Display backup information
display_info() {
    echo "========================================="
    echo "$SCRIPT_NAME"
    echo "========================================="
    echo "Hostname: $HOSTNAME"
    echo "Date: $(date)"
    echo "Backup directories: $BACKUP_DIRS"
    echo "Backup destination: $BACKUP_DEST/$ARCHIVE_FILE"
    echo "Log file: $LOG_FILE"
    echo "========================================="
    echo ""
}

# Perform the backup
perform_backup() {
    echo "Starting backup..."
    START_TIME=$(date +%s)
    
    # Create the backup with progress indication
    tar czf "$BACKUP_DEST/$ARCHIVE_FILE" \
        $EXCLUDE_ARGS \
        $BACKUP_DIRS \
        2>&1 | tee -a "$LOG_FILE"
    
    # Check if tar succeeded
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        END_TIME=$(date +%s)
        DURATION=$((END_TIME - START_TIME))
        
        echo ""
        echo "========================================="
        echo "Backup completed successfully!"
        echo "Duration: $((DURATION / 60)) minutes $((DURATION % 60)) seconds"
        echo "========================================="
        
        # Display backup file information
        if [ -f "$BACKUP_DEST/$ARCHIVE_FILE" ]; then
            echo ""
            echo "Backup file details:"
            ls -lh "$BACKUP_DEST/$ARCHIVE_FILE"
            
            # Calculate and display disk usage
            echo ""
            echo "Backup destination disk usage:"
            df -h "$BACKUP_DEST"
        fi
        
        return 0
    else
        echo ""
        echo "========================================="
        echo "ERROR: Backup failed!"
        echo "Check the log file for details: $LOG_FILE"
        echo "========================================="
        return 1
    fi
}

# Cleanup old backups (keep last 7 days)
cleanup_old_backups() {
    echo ""
    echo "Cleaning up old backups (keeping last 7 days)..."
    find "$BACKUP_DEST" -name "$HOSTNAME-*.tar.gz" -type f -mtime +7 -delete
    echo "Cleanup completed."
}

####################################
# Main Script
####################################

# Run checks
check_root
check_destination

# Build exclude arguments
build_exclude_args

# Display information
display_info

# Ask for confirmation
read -p "Do you want to proceed with the backup? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Backup cancelled."
    exit 0
fi

# Perform the backup
if perform_backup; then
    # Cleanup old backups
    cleanup_old_backups
    
    echo ""
    echo "All backup operations completed successfully!"
    exit 0
else
    exit 1
fi
