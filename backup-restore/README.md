# System Backup and Restore Scripts

A collection of bash scripts for creating full and incremental backups of your Linux system, based on Ubuntu's official backup documentation.

## Scripts Overview

### 1. `full-system-backup.sh`
Creates a complete compressed backup of important system directories.

**Features:**
- Backs up: `/home`, `/etc`, `/var`, `/root`, `/boot`, `/opt`, `/usr/local`
- Automatically excludes cache and temporary files
- Named backups by day of the week (Monday, Tuesday, etc.)
- Automatic cleanup of backups older than 7 days
- Progress indication and detailed logging
- Confirmation prompt before starting

**Usage:**
```bash
sudo ./full-system-backup.sh
```

### 2. `incremental-backup.sh`
Creates incremental backups that only store changed files since the last backup.

**Features:**
- Initial full backup creates a baseline
- Subsequent backups only store changed files
- Much faster and smaller than full backups
- Uses tar's snapshot feature to track changes
- Interactive selection between full and incremental

**Usage:**
```bash
# First time (creates full backup)
sudo ./incremental-backup.sh

# Subsequent runs (incremental)
sudo ./incremental-backup.sh
```

### 3. `restore-backup.sh`
Interactive script to restore files from backups.

**Features:**
- List all available backups
- View contents of backup archives
- Restore individual files to a test location
- Full system restore (with safety warnings)
- Both interactive and command-line modes

**Usage:**
```bash
# Interactive mode
sudo ./restore-backup.sh

# List backups
sudo ./restore-backup.sh --list

# View backup contents
sudo ./restore-backup.sh --contents /mnt/backup/hostname-Monday.tar.gz

# Restore specific file to /tmp (safe testing)
sudo ./restore-backup.sh --restore-file /mnt/backup/hostname-Monday.tar.gz /etc/fstab /tmp

# Full system restore (DANGEROUS!)
sudo ./restore-backup.sh --restore-full /mnt/backup/hostname-Monday.tar.gz
```

## Setup Instructions

### 1. Prepare Backup Destination

Create a backup directory or mount an external drive:

```bash
# Option A: Create a local backup directory
sudo mkdir -p /mnt/backup
sudo chmod 700 /mnt/backup

# Option B: Mount an external drive
sudo mkdir -p /mnt/backup
sudo mount /dev/sdX1 /mnt/backup  # Replace sdX1 with your drive

# Option C: Mount a network share (NFS)
sudo mkdir -p /mnt/backup
sudo mount -t nfs server:/backup /mnt/backup
```

### 2. Make Scripts Executable

```bash
chmod +x full-system-backup.sh
chmod +x incremental-backup.sh
chmod +x restore-backup.sh
```

### 3. Configure Backup Location

Edit the scripts and change the `BACKUP_DEST` variable if needed:

```bash
# Default is /mnt/backup
BACKUP_DEST="/mnt/backup"

# Examples:
# BACKUP_DEST="/media/external-drive/backups"
# BACKUP_DEST="/backup"
```

### 4. Customize What to Backup

Edit the `BACKUP_DIRS` variable in the scripts:

```bash
# Default directories
BACKUP_DIRS="/home /etc /var /root /boot /opt /usr/local"

# Add or remove directories as needed
```

## Automating Backups with Cron

To run automatic backups, add a cron job:

```bash
# Edit root's crontab
sudo crontab -e

# Examples:

# Daily full backup at 2:00 AM
0 2 * * * /home/mate/repos/dotfiles/backup-restore/full-system-backup.sh

# Daily incremental backup at 2:00 AM
0 2 * * * /home/mate/repos/dotfiles/backup-restore/incremental-backup.sh

# Weekly full backup on Sunday at 3:00 AM
0 3 * * 0 /home/mate/repos/dotfiles/backup-restore/full-system-backup.sh
```

### Cron Schedule Format

```
# ┌───────────── minute (0 - 59)
# │ ┌───────────── hour (0 - 23)
# │ │ ┌───────────── day of month (1 - 31)
# │ │ │ ┌───────────── month (1 - 12)
# │ │ │ │ ┌───────────── day of week (0 - 6) (Sunday to Saturday)
# │ │ │ │ │
# * * * * * command
```

## Backup Strategies

### Strategy 1: Daily Full Backups (Simple)
- Run `full-system-backup.sh` daily
- Keeps 7 days of backups automatically
- Easy to restore, but uses more disk space

### Strategy 2: Incremental Backups (Efficient)
- Run full backup weekly (Sunday)
- Run incremental backup daily (Monday-Saturday)
- Uses less disk space and faster
- Requires all incremental files to restore

### Strategy 3: Weekly Rotation
- Keep different backups for each day of week
- Automatically overwrites last week's backup
- Good balance of space and history

## Testing Your Backups

**Always test your backups!** Here's how:

```bash
# 1. List what's in the backup
sudo ./restore-backup.sh --contents /mnt/backup/hostname-Monday.tar.gz

# 2. Restore a test file to /tmp
sudo ./restore-backup.sh --restore-file /mnt/backup/hostname-Monday.tar.gz /etc/fstab /tmp

# 3. Verify the restored file
cat /tmp/etc/fstab
```

## Important Notes

### Security
- Scripts require root privileges (use `sudo`)
- Backup files contain sensitive system data
- Protect your backups with appropriate permissions
- Consider encrypting backups for sensitive data

### Disk Space
- Full backups can be several GB depending on your system
- Monitor disk space: `df -h /mnt/backup`
- The scripts automatically clean up old backups

### What's NOT Backed Up
By default, these directories are excluded to save space:
- `/var/cache` - Package cache
- `/var/tmp` - Temporary files
- `/var/log` - Log files (can be huge)
- `/home/*/.cache` - User cache directories
- `/home/*/.local/share/Trash` - Trash folders

### System-Specific Directories Not Included
These are typically not backed up (they're recreated on boot):
- `/dev` - Device files
- `/proc` - Process information
- `/sys` - System information
- `/tmp` - Temporary files
- `/run` - Runtime data
- `/mnt` - Mount points
- `/media` - Removable media

## Restoring After System Failure

### Method 1: Restore Individual Files (Recommended)
Boot from a live USB and restore specific files:

```bash
# Mount your system partition
sudo mount /dev/sdaX /mnt/system

# Mount backup drive
sudo mount /dev/sdaY /mnt/backup

# Extract backup to mounted system
cd /mnt/system
sudo tar -xzvf /mnt/backup/hostname-Monday.tar.gz
```

### Method 2: Full System Restore
Only use if you need to restore everything:

```bash
# Boot from live USB
# Mount system partition to /mnt/system
sudo mount /dev/sdaX /mnt/system

# Restore backup
cd /mnt/system
sudo tar -xzvf /mnt/backup/hostname-Monday.tar.gz

# Reinstall bootloader if needed
sudo grub-install /dev/sda
sudo update-grub
```

## Additional Resources

- [Ubuntu Backup Documentation](https://documentation.ubuntu.com/server/how-to/backups/back-up-using-shell-scripts/)
- [GNU tar Manual](http://www.gnu.org/software/tar/manual/index.html)
- [Advanced Bash-Scripting Guide](http://tldp.org/LDP/abs/html/)

## Alternative Tools

Consider these more advanced backup solutions:
- **rsnapshot** - Automated filesystem snapshots using rsync
- **Bacula** - Enterprise-grade backup solution
- **Borg Backup** - Deduplicating backup program
- **Timeshift** - System restore utility (Ubuntu)
- **rsync** - For incremental backups to remote systems

## License

These scripts are based on Ubuntu's official documentation and are provided as-is for personal use.
