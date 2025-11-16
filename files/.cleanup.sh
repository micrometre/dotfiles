#!/bin/bash
####################################
#
# System Cleanup Script
# Clears cache and temporary files before backup
#
####################################

# Configuration
SCRIPT_NAME="Pre-Backup Cleanup"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

####################################
# Functions
####################################

# Check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then 
        echo -e "${RED}ERROR: This script must be run as root (use sudo)${NC}"
        exit 1
    fi
}

# Display header
display_header() {
    echo "========================================="
    echo "$SCRIPT_NAME"
    echo "========================================="
    echo "Hostname: $(hostname -s)"
    echo "Date: $(date)"
    echo "========================================="
    echo ""
}

# Calculate disk usage before cleanup
calculate_before() {
    echo -e "${YELLOW}Calculating current disk usage...${NC}"
    DISK_BEFORE=$(df / | tail -1 | awk '{print $3}')
    echo ""
}

# Clean package manager cache
clean_package_cache() {
    echo -e "${GREEN}[1/9] Cleaning APT package cache...${NC}"
    apt-get clean
    apt-get autoclean
    echo "✓ APT cache cleaned"
    echo ""
}

# Clean old kernels (keep current and one previous)
clean_old_kernels() {
    echo -e "${GREEN}[2/9] Checking for old kernels...${NC}"
    CURRENT_KERNEL=$(uname -r)
    echo "Current kernel: $CURRENT_KERNEL"
    
    OLD_KERNELS=$(dpkg -l | grep -E 'linux-image-[0-9]' | grep -v "$CURRENT_KERNEL" | awk '{print $2}')
    
    if [ -z "$OLD_KERNELS" ]; then
        echo "No old kernels to remove"
    else
        echo "Old kernels found (will not auto-remove, manual action required):"
        echo "$OLD_KERNELS"
        echo "To remove manually: sudo apt-get remove --purge <kernel-name>"
    fi
    echo ""
}

# Clean thumbnail cache
clean_thumbnails() {
    echo -e "${GREEN}[3/9] Cleaning thumbnail cache...${NC}"
    for user_home in /home/*; do
        if [ -d "$user_home/.cache/thumbnails" ]; then
            rm -rf "$user_home/.cache/thumbnails"/*
            echo "✓ Cleaned thumbnails for $(basename "$user_home")"
        fi
    done
    
    # Root user thumbnails
    if [ -d "/root/.cache/thumbnails" ]; then
        rm -rf /root/.cache/thumbnails/*
        echo "✓ Cleaned thumbnails for root"
    fi
    echo ""
}

# Clean user cache directories
clean_user_cache() {
    echo -e "${GREEN}[4/9] Cleaning user cache directories...${NC}"
    for user_home in /home/*; do
        if [ -d "$user_home/.cache" ]; then
            CACHE_SIZE=$(du -sh "$user_home/.cache" 2>/dev/null | awk '{print $1}')
            echo "Cleaning cache for $(basename "$user_home") (Size: $CACHE_SIZE)"
            
            # Clean specific cache directories but preserve structure
            find "$user_home/.cache" -type f -delete 2>/dev/null
            find "$user_home/.cache" -type d -empty -delete 2>/dev/null
        fi
    done
    
    # Root user cache
    if [ -d "/root/.cache" ]; then
        CACHE_SIZE=$(du -sh /root/.cache 2>/dev/null | awk '{print $1}')
        echo "Cleaning cache for root (Size: $CACHE_SIZE)"
        find /root/.cache -type f -delete 2>/dev/null
        find /root/.cache -type d -empty -delete 2>/dev/null
    fi
    echo ""
}

# Clean trash
clean_trash() {
    echo -e "${GREEN}[5/9] Cleaning user trash directories...${NC}"
    for user_home in /home/*; do
        if [ -d "$user_home/.local/share/Trash" ]; then
            TRASH_SIZE=$(du -sh "$user_home/.local/share/Trash" 2>/dev/null | awk '{print $1}')
            if [ "$TRASH_SIZE" != "0" ]; then
                echo "Emptying trash for $(basename "$user_home") (Size: $TRASH_SIZE)"
                rm -rf "$user_home/.local/share/Trash"/*
            fi
        fi
    done
    echo ""
}

# Clean temporary files
clean_tmp() {
    echo -e "${GREEN}[6/9] Cleaning temporary files...${NC}"
    
    # /tmp
    TMP_SIZE=$(du -sh /tmp 2>/dev/null | awk '{print $1}')
    echo "Cleaning /tmp (Size: $TMP_SIZE)"
    find /tmp -type f -atime +7 -delete 2>/dev/null
    find /tmp -type d -empty -delete 2>/dev/null
    
    # /var/tmp
    VAR_TMP_SIZE=$(du -sh /var/tmp 2>/dev/null | awk '{print $1}')
    echo "Cleaning /var/tmp (Size: $VAR_TMP_SIZE)"
    find /var/tmp -type f -atime +7 -delete 2>/dev/null
    find /var/tmp -type d -empty -delete 2>/dev/null
    
    echo ""
}

# Clean system cache
clean_system_cache() {
    echo -e "${GREEN}[7/9] Cleaning system cache...${NC}"
    
    if [ -d "/var/cache" ]; then
        VAR_CACHE_SIZE=$(du -sh /var/cache 2>/dev/null | awk '{print $1}')
        echo "Current /var/cache size: $VAR_CACHE_SIZE"
        
        # Clean apt cache
        if [ -d "/var/cache/apt/archives" ]; then
            rm -f /var/cache/apt/archives/*.deb
            rm -f /var/cache/apt/archives/partial/*.deb
            echo "✓ Cleaned APT archives"
        fi
        
        # Clean other cache directories (be selective)
        find /var/cache -type f -name "*.cache" -delete 2>/dev/null
    fi
    echo ""
}

# Clean old logs
clean_old_logs() {
    echo -e "${GREEN}[8/9] Cleaning old log files...${NC}"
    
    if [ -d "/var/log" ]; then
        LOG_SIZE=$(du -sh /var/log 2>/dev/null | awk '{print $1}')
        echo "Current /var/log size: $LOG_SIZE"
        
        # Clean rotated logs older than 7 days
        find /var/log -type f -name "*.gz" -mtime +7 -delete 2>/dev/null
        find /var/log -type f -name "*.1" -mtime +7 -delete 2>/dev/null
        find /var/log -type f -name "*.old" -mtime +7 -delete 2>/dev/null
        
        # Truncate large log files (keep last 1000 lines)
        for log in /var/log/*.log; do
            if [ -f "$log" ]; then
                SIZE=$(stat -c%s "$log" 2>/dev/null)
                if [ "$SIZE" -gt 10485760 ]; then  # > 10MB
                    echo "Truncating large log: $(basename "$log") ($(numfmt --to=iec-i --suffix=B "$SIZE"))"
                    tail -n 1000 "$log" > "$log.tmp"
                    mv "$log.tmp" "$log"
                fi
            fi
        done
        
        echo "✓ Old logs cleaned"
    fi
    echo ""
}

# Clean journal logs
clean_journal() {
    echo -e "${GREEN}[9/9] Cleaning systemd journal logs...${NC}"
    
    if command -v journalctl &> /dev/null; then
        JOURNAL_SIZE=$(journalctl --disk-usage 2>/dev/null | grep -oP '\d+\.\d+[GM]')
        echo "Current journal size: $JOURNAL_SIZE"
        
        # Keep only last 7 days
        journalctl --vacuum-time=7d 2>/dev/null
        
        NEW_JOURNAL_SIZE=$(journalctl --disk-usage 2>/dev/null | grep -oP '\d+\.\d+[GM]')
        echo "New journal size: $NEW_JOURNAL_SIZE"
    fi
    echo ""
}

# Calculate disk usage after cleanup
calculate_after() {
    echo -e "${YELLOW}Calculating disk usage after cleanup...${NC}"
    DISK_AFTER=$(df / | tail -1 | awk '{print $3}')
    DISK_FREED=$((DISK_BEFORE - DISK_AFTER))
    DISK_FREED_MB=$((DISK_FREED / 1024))
    
    echo ""
    echo "========================================="
    echo "Cleanup Summary"
    echo "========================================="
    echo "Space freed: ${DISK_FREED_MB} MB"
    echo ""
    echo "Current disk usage:"
    df -h /
    echo "========================================="
}

####################################
# Main Script
####################################

check_root
display_header

# Ask for confirmation
read -p "This will clean cache, temporary files, and old logs. Continue? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cleanup cancelled."
    exit 0
fi

echo ""
START_TIME=$(date +%s)

calculate_before

# Perform cleanup operations
clean_package_cache
clean_old_kernels
clean_thumbnails
clean_user_cache
clean_trash
clean_tmp
clean_system_cache
clean_old_logs
clean_journal

calculate_after

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo ""
echo "Cleanup completed in $DURATION seconds"
echo ""
echo -e "${GREEN}System is ready for backup!${NC}"

exit 0
