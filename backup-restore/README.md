# System Backup, Restore, and VM Conversion Scripts

A collection of bash scripts for cleaning up your Linux system, creating full and incremental backups, restoring files, and converting backups into Virtual Machine (VM) disk images.

## Scripts Overview

| Script | Purpose |
|--------|---------|
| [`cleanup-before-backup.sh`](./cleanup-before-backup.sh) | Cleans caches, temporary files, trash, and old logs before running a backup |
| [`full-system-backup.sh`](./full-system-backup.sh) | Creates a complete compressed `.tar.gz` backup of key system directories |
| [`incremental-backup.sh`](./incremental-backup.sh) | Creates snapshot-based full baseline and incremental `.tar.gz` backups |
| [`restore-backup.sh`](./restore-backup.sh) | Lists, inspects, and restores individual files or full systems from backups |
| [`backup-to-vm-image.sh`](./backup-to-vm-image.sh) | Converts a `.tar.gz` backup into a **bootable** raw VM disk image (`.img`) with GRUB |
| [`backup-to-data-disk.sh`](./backup-to-data-disk.sh) | Converts a `.tar.gz` backup into a **non-bootable** `ext4` data disk image (`-data.img`) |

---

### 1. `cleanup-before-backup.sh` (and `../scripts/.cleanup.sh`)
Reclaims disk space and shrinks backup size by clearing caches, temporary files, and old logs prior to creating a backup.

> **Note:** An enhanced version with CLI flags (`-n`/`--dry-run`, `-y`/`--yes`, `-h`/`--help`) is also available at [`../scripts/.cleanup.sh`](../scripts/.cleanup.sh) (designed to be installed at `~/.cleanup.sh` and invoked via the `cleanup`, `cleanup-real`, and `cleanup_system` aliases in [`../files/.bash_aliases`](../files/.bash_aliases)).

**Features:**
- **[1/9] APT Cache:** Runs `apt-get clean` and `apt-get autoclean`
- **[2/9] Old Kernels:** Checks for and lists older installed kernel images (does not auto-remove)
- **[3/9] Thumbnail Cache:** Clears `~/.cache/thumbnails` for all users and `root`
- **[4/9] User Cache:** Removes cached files in `/home/*/.cache` and `/root/.cache` while keeping directory structure
- **[5/9] Trash:** Empties `/home/*/.local/share/Trash`
- **[6/9] Temporary Files:** Removes files not accessed in >7 days from `/tmp` and `/var/tmp`
- **[7/9] System Cache:** Removes `.deb` archives and `*.cache` files from `/var/cache`
- **[8/9] Log Files:** Deletes rotated logs (`*.gz`, `*.1`, `*.old`) older than 7 days and truncates `.log` files larger than 10MB to their last 1,000 lines
- **[9/9] Systemd Journal:** Vacuums systemd journal logs to the last 7 days (`journalctl --vacuum-time=7d`)
- Reports total disk space freed (in MB) and execution time

**Usage:**
```bash
# Run interactive pre-backup cleanup
sudo ./cleanup-before-backup.sh

# Or using the enhanced script with flags
sudo ../scripts/.cleanup.sh --dry-run
sudo ../scripts/.cleanup.sh --yes
```

---

### 2. `full-system-backup.sh`
Creates a complete compressed backup of important system directories.

**Features:**
- Backs up: `/home`, `/etc`, `/var`, `/root`, `/boot`, `/opt`, `/usr/local`, `/srv`
- Automatically excludes cache, temporary, log, Docker, and Snap runtime directories
- Archive naming includes hostname, day of week, and timestamp: `<hostname>-<Day>-<YYYY-MM-DD_HH-MM-SS>.tar.gz`
- Logs output to `/mnt/backup/backup-<YYYY-MM-DD_HH-MM-SS>.log`
- Automatic cleanup of backups older than 7 days (`-mtime +7`)
- Confirmation prompt before starting

**Usage:**
```bash
sudo ./full-system-backup.sh
```

---

### 3. `incremental-backup.sh`
Creates incremental backups that only store changed files since the last backup using GNU `tar` listed-incremental snapshots.

**Features:**
- Stores archives in `/mnt/backup/incremental/` and snapshot metadata in `/mnt/backup/snapshots/<hostname>.snar`
- Initial run automatically performs a full baseline backup (`<hostname>-full-<timestamp>.tar.gz`)
- Subsequent runs let you choose interactively between:
  1. **Incremental** (`<hostname>-incremental-<timestamp>.tar.gz` — only changed files)
  2. **Full** (resets snapshot file and creates a new baseline)
- Backs up and excludes the same directories as `full-system-backup.sh`

**Usage:**
```bash
# First run (automatically creates full baseline backup)
sudo ./incremental-backup.sh

# Subsequent runs (choose 1 for Incremental or 2 for new Full baseline)
sudo ./incremental-backup.sh
```

---

### 4. `restore-backup.sh`
Interactive and CLI utility to inspect and restore files from backup archives in `/mnt/backup`.

**Features:**
- List all available `.tar.gz` backups in `/mnt/backup`
- Preview the first 50 files and total file count of an archive
- Restore individual files to a safe test directory (e.g., `/tmp`) or live path
- Full system restore to `/` (requires typing `YES` to confirm)
- Supports both interactive menu and command-line flags

**Usage:**
```bash
# Interactive mode
sudo ./restore-backup.sh

# List available backups
sudo ./restore-backup.sh --list

# View backup contents
sudo ./restore-backup.sh --contents /mnt/backup/hostname-Monday-2026-11-10_02-00-00.tar.gz

# Restore a specific file to /tmp (safe testing)
sudo ./restore-backup.sh --restore-file /mnt/backup/hostname-Monday-2026-11-10_02-00-00.tar.gz /etc/fstab /tmp

# Full system restore (DANGEROUS!)
sudo ./restore-backup.sh --restore-full /mnt/backup/hostname-Monday-2026-11-10_02-00-00.tar.gz
```

---

### 5. `backup-to-vm-image.sh`
Converts a `.tar.gz` backup archive into a **bootable** raw disk image (`.img`) ready for QEMU/KVM or VirtualBox.

**Prerequisites:**
- `qemu-utils` (`qemu-img`)
- `parted`
- `e2fsprogs` (`mkfs.ext4`)

Install dependencies if missing:
```bash
sudo apt install qemu-utils parted e2fsprogs
```

**How It Works (8 Steps):**
1. Allocates a raw `.img` file of the requested size (minimum 10GB; 20–50GB recommended)
2. Creates an `msdos` partition table with a bootable primary `ext4` partition
3. Attaches the image to a loop device (`losetup -fP`)
4. Formats the partition as `ext4`
5. Mounts the partition to a temporary mount point (`/mnt/vm-temp-$$`)
6. Extracts the `.tar.gz` backup preserving permissions (`tar -xzpf`)
7. Recreates essential runtime directories (`/dev`, `/proc`, `/sys`, `/run`, `/tmp`, `/mnt`, `/media`, `/boot/grub`) and generates `/etc/fstab` with the new partition's `UUID`
8. Bind-mounts `/dev`, `/proc`, and `/sys`, then `chroot`s into the image to install GRUB (`grub-install --target=i386-pc`) and run `update-grub`

**Usage:**
```bash
sudo ./backup-to-vm-image.sh
```

---

### 6. `backup-to-data-disk.sh`
Converts a `.tar.gz` backup archive into a **non-bootable** `ext4` data disk image (`<backup-name>-data.img`).

**Features:**
- Simpler and faster than `backup-to-vm-image.sh` (no partition table, `chroot`, or GRUB installation)
- Ideal for attaching as a secondary disk to an existing VM or loop-mounting on the host to browse and verify backed-up files

**Usage:**
```bash
sudo ./backup-to-data-disk.sh
```

---

## Using Backups with Virtual Machines (VMs)

You can turn any system backup into a virtual disk to test disaster recovery, inspect system state in isolation, or migrate a physical machine to a VM (P2V).

### Option A: Bootable VM Image (`backup-to-vm-image.sh`)

After running `sudo ./backup-to-vm-image.sh`, an image file `/mnt/backup/<backup-name>.img` is created.

#### Run Directly in QEMU/KVM (Raw Image)
```bash
qemu-system-x86_64 -enable-kvm -m 2048 -smp 2 -hda /mnt/backup/<backup-name>.img
```

#### Convert to `qcow2` for QEMU/KVM / libvirt (`virt-manager`)
```bash
qemu-img convert -f raw -O qcow2 \
  /mnt/backup/<backup-name>.img \
  /mnt/backup/<backup-name>.qcow2

# Boot the qcow2 image
qemu-system-x86_64 -enable-kvm -m 2048 -smp 2 -hda /mnt/backup/<backup-name>.qcow2
```

#### Convert to `VDI` for VirtualBox
```bash
VBoxManage convertfromraw \
  /mnt/backup/<backup-name>.img \
  /mnt/backup/<backup-name>.vdi \
  --format VDI
```

### Option B: Secondary Data Disk (`backup-to-data-disk.sh`)

If you don't need to boot the backup directly (or if the backup did not include a kernel/GRUB), create a data disk with `sudo ./backup-to-data-disk.sh`.

#### Attach as a Secondary Disk in QEMU/KVM
```bash
qemu-system-x86_64 -enable-kvm -m 2048 \
  -hda main-vm.qcow2 \
  -hdb /mnt/backup/<backup-name>-data.img
```

#### Mount Directly on Host to Inspect Files
```bash
sudo mkdir -p /mnt/test
sudo mount -o loop /mnt/backup/<backup-name>-data.img /mnt/test
ls -la /mnt/test
sudo umount /mnt/test
```

#### Convert Data Disk to `qcow2`
```bash
qemu-img convert -f raw -O qcow2 \
  /mnt/backup/<backup-name>-data.img \
  /mnt/backup/<backup-name>-data.qcow2
```

---

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
chmod +x cleanup-before-backup.sh \
         full-system-backup.sh \
         incremental-backup.sh \
         restore-backup.sh \
         backup-to-vm-image.sh \
         backup-to-data-disk.sh
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

Edit the `BACKUP_DIRS` variable in `full-system-backup.sh` and `incremental-backup.sh`:

```bash
# Default directories
BACKUP_DIRS="/home /etc /var /root /boot /opt /usr/local /srv"
```

## Automating Backups with Cron

To run automatic backups (Note: `full-system-backup.sh` prompts for confirmation interactively unless adapted for non-interactive cron runs), add a cron job:

```bash
# Edit root's crontab
sudo crontab -e

# Examples:

# Daily full backup at 2:00 AM
0 2 * * * /home/ubuntu/repos/dotfiles/backup-restore/full-system-backup.sh

# Daily incremental backup at 2:00 AM
0 2 * * * /home/ubuntu/repos/dotfiles/backup-restore/incremental-backup.sh

# Weekly full backup on Sunday at 3:00 AM
0 3 * * 0 /home/ubuntu/repos/dotfiles/backup-restore/full-system-backup.sh
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

### Strategy 1: Pre-Cleanup + Full Backup (Recommended Before Major Changes)
1. Run `sudo ./cleanup-before-backup.sh` to purge caches and old logs
2. Run `sudo ./full-system-backup.sh` to create a clean archive
3. Optionally run `sudo ./backup-to-vm-image.sh` or `sudo ./backup-to-data-disk.sh` to verify the backup in a VM

### Strategy 2: Daily Full Backups (Simple)
- Run `full-system-backup.sh` daily
- Keeps 7 days of backups automatically
- Easy to restore, but uses more disk space

### Strategy 3: Incremental Backups (Space-Efficient)
- Run a full baseline backup weekly
- Run incremental backups daily
- Uses less disk space and completes much faster
- Requires the baseline archive plus subsequent incremental archives to restore

## Testing Your Backups

**Always test your backups!** Here are three ways:

```bash
# 1. List what's in the backup
sudo ./restore-backup.sh --contents /mnt/backup/hostname-Monday-2026-11-10_02-00-00.tar.gz

# 2. Restore a test file to /tmp
sudo ./restore-backup.sh --restore-file /mnt/backup/hostname-Monday-2026-11-10_02-00-00.tar.gz /etc/fstab /tmp
cat /tmp/etc/fstab

# 3. Convert to a VM data disk or bootable VM image and inspect in QEMU
sudo ./backup-to-data-disk.sh
```

## Important Notes

### Security
- Scripts require root privileges (use `sudo`)
- Backup files contain sensitive system data (`/etc/shadow`, SSH keys, etc.)
- Protect your backups with appropriate permissions (`chmod 700 /mnt/backup`)
- Consider encrypting backups when storing on external or off-site media

### Disk Space
- Full backups can be several GB depending on your system
- Monitor disk space: `df -h /mnt/backup`
- Creating a VM disk image requires free space equal to the chosen virtual disk size (e.g., 20–50GB)

### What's NOT Backed Up
By default, these directories are excluded in `full-system-backup.sh` and `incremental-backup.sh` to save space and avoid recursion:
- `/var/cache` - Package cache
- `/var/tmp` - Temporary files
- `/var/log` - Log files (can be huge)
- `/var/backups` - System backup files
- `/var/lib/docker` - Docker images, containers, and volumes
- `/var/snap` - Snap package runtime data
- `/home/*/.cache` - User cache directories
- `/home/*/.local/share/Trash` - Trash folders

### System-Specific Directories Not Included
These virtual or runtime filesystems are not backed up (they are recreated on boot or by `backup-to-vm-image.sh`):
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

# Extract specific path or full backup to mounted system
cd /mnt/system
sudo tar -xzvf /mnt/backup/hostname-Monday-2026-11-10_02-00-00.tar.gz
```

### Method 2: Full System Restore
Only use if you need to restore everything:

```bash
# Boot from live USB
# Mount system partition to /mnt/system
sudo mount /dev/sdaX /mnt/system

# Restore backup
cd /mnt/system
sudo tar -xzvf /mnt/backup/hostname-Monday-2026-11-10_02-00-00.tar.gz

# Reinstall bootloader if needed
sudo grub-install /dev/sda
sudo update-grub
```

## Additional Resources

- [Ubuntu Backup Documentation](https://documentation.ubuntu.com/server/how-to/backups/back-up-using-shell-scripts/)
- [GNU tar Manual](https://www.gnu.org/software/tar/manual/index.html)
- [QEMU Disk Images Documentation](https://www.qemu.org/docs/master/system/images.html)

## Alternative Tools

Consider these more advanced backup solutions:
- **rsnapshot** - Automated filesystem snapshots using rsync
- **Bacula** - Enterprise-grade backup solution
- **Borg Backup** - Deduplicating backup program
- **Timeshift** - System restore utility (Ubuntu)
- **rsync** - For incremental backups to remote systems

## License

These scripts are based on Ubuntu's official documentation and are provided as-is for personal use.
