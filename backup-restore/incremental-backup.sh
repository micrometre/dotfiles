#!/bin/bash
####################################
#
# Incremental Backup Script
# Uses tar with incremental snapshots
#
####################################

# Configuration
SCRIPT_NAME="Incremental System Backup"
BACKUP_DATE=$(date +%Y-%m-%d_%H-%M-%S)
HOSTNAME=$(hostname -s)

# What to backup - Based on actual system directories
# Note: /snap contains snaps (3.0G), /boot has kernel images (211M)
# /srv is typically for service data (4.0K - currently empty)
# /home (5.2G), /var (1.5G), /opt (374M), /etc (24M), /usr/local (100K), /root (4.0K)
BACKUP_DIRS="/home /etc /var /root /boot /opt /usr/local /srv"

# Exclude directories (to reduce backup size and avoid issues)
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

# Backup destination
BACKUP_DEST="/mnt/backup"
SNAPSHOT_DIR="$BACKUP_DEST/snapshots"
INCREMENTAL_DIR="$BACKUP_DEST/incremental"

# Snapshot file for tracking changes
SNAPSHOT_FILE="$SNAPSHOT_DIR/$HOSTNAME.snar"

# Archive filename
ARCHIVE_FILE="$HOSTNAME-incremental-$BACKUP_DATE.tar.gz"

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
        echo "ERROR: Backup destination $BACKUP_DEST does not exist"
        exit 1
    fi
    
    # Create subdirectories if they don't exist
    mkdir -p "$SNAPSHOT_DIR" "$INCREMENTAL_DIR"
}

build_exclude_args() {
    EXCLUDE_ARGS=""
    for dir in "${EXCLUDE_DIRS[@]}"; do
        EXCLUDE_ARGS="$EXCLUDE_ARGS --exclude=$dir"
    done
}

perform_full_backup() {
    echo "Performing FULL backup..."
    echo "This will create a new snapshot baseline."
    echo ""
    
    # Remove old snapshot file to start fresh
    rm -f "$SNAPSHOT_FILE"
    
    tar czf "$INCREMENTAL_DIR/$HOSTNAME-full-$BACKUP_DATE.tar.gz" \
        --listed-incremental="$SNAPSHOT_FILE" \
        $EXCLUDE_ARGS \
        $BACKUP_DIRS
    
    if [ $? -eq 0 ]; then
        echo "Full backup completed successfully!"
        echo "File: $INCREMENTAL_DIR/$HOSTNAME-full-$BACKUP_DATE.tar.gz"
        ls -lh "$INCREMENTAL_DIR/$HOSTNAME-full-$BACKUP_DATE.tar.gz"
        return 0
    else
        echo "ERROR: Full backup failed!"
        return 1
    fi
}

perform_incremental_backup() {
    echo "Performing INCREMENTAL backup..."
    echo "Only backing up files changed since last backup."
    echo ""
    
    if [ ! -f "$SNAPSHOT_FILE" ]; then
        echo "ERROR: No snapshot file found. Please run a full backup first."
        exit 1
    fi
    
    tar czf "$INCREMENTAL_DIR/$ARCHIVE_FILE" \
        --listed-incremental="$SNAPSHOT_FILE" \
        $EXCLUDE_ARGS \
        $BACKUP_DIRS
    
    if [ $? -eq 0 ]; then
        echo "Incremental backup completed successfully!"
        echo "File: $INCREMENTAL_DIR/$ARCHIVE_FILE"
        ls -lh "$INCREMENTAL_DIR/$ARCHIVE_FILE"
        return 0
    else
        echo "ERROR: Incremental backup failed!"
        return 1
    fi
}

show_backup_info() {
    echo "========================================="
    echo "$SCRIPT_NAME"
    echo "========================================="
    echo "Hostname: $HOSTNAME"
    echo "Date: $(date)"
    echo ""
    
    if [ -f "$SNAPSHOT_FILE" ]; then
        echo "Snapshot file exists: YES"
        echo "Last modified: $(stat -c %y "$SNAPSHOT_FILE")"
    else
        echo "Snapshot file exists: NO (full backup required)"
    fi
    
    echo ""
    echo "Existing backups in $INCREMENTAL_DIR:"
    ls -lh "$INCREMENTAL_DIR" | grep "$HOSTNAME" || echo "No backups found"
    echo "========================================="
    echo ""
}

####################################
# Main Script
####################################

check_root
check_destination
build_exclude_args
show_backup_info

# Determine backup type
if [ ! -f "$SNAPSHOT_FILE" ]; then
    echo "No snapshot file found. A full backup will be performed."
    BACKUP_TYPE="full"
else
    echo "Select backup type:"
    echo "1) Incremental (only changed files)"
    echo "2) Full (new baseline)"
    read -p "Enter choice (1 or 2): " choice
    
    case $choice in
        1)
            BACKUP_TYPE="incremental"
            ;;
        2)
            BACKUP_TYPE="full"
            ;;
        *)
            echo "Invalid choice. Exiting."
            exit 1
            ;;
    esac
fi

echo ""
START_TIME=$(date +%s)

if [ "$BACKUP_TYPE" = "full" ]; then
    perform_full_backup
    RESULT=$?
else
    perform_incremental_backup
    RESULT=$?
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo ""
echo "========================================="
echo "Backup completed in $((DURATION / 60)) minutes $((DURATION % 60)) seconds"
echo "Disk usage:"
df -h "$BACKUP_DEST"
echo "========================================="

exit $RESULT
