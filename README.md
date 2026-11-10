# 🐧 Dotfiles & System Configuration

A comprehensive collection of configuration files, automation scripts, and Ansible playbooks for setting up and managing Debian-based Linux systems (Ubuntu/Debian). This repository provides everything needed for quick system setup, from development environments to production servers.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ansible](https://img.shields.io/badge/Ansible-Automation-red.svg)](https://www.ansible.com/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-Compatible-orange.svg)](https://ubuntu.com/)

## 📋 Table of Contents

- [Features](#-features)
- [Quick Start](#-quick-start)
- [Directory Structure](#-directory-structure)
- [Ansible Automation](#-ansible-automation)
- [Configuration Files](#-configuration-files)
- [Utility Scripts](#-utility-scripts)
- [System Backup & Restore](#-system-backup--restore)
- [Shell Aliases & Functions](#-shell-aliases--functions)
- [Installation](#-installation)
- [Usage Examples](#-usage-examples)
- [Requirements](#-requirements)
- [Contributing](#-contributing)

## ✨ Features

### 🔧 Automated System Setup
- **Ansible Playbooks**: Fully automated system configuration for servers and workstations
- **Role-Based Configuration**: Modular setup for Docker, Python, Node.js, Nginx, KVM, and more
- **VM Management**: Complete KVM/libvirt automation with cloud-init support
- **Security Hardening**: SSH security, Fail2ban configuration, and user management

### 🎨 Development Environment
- **Vim IDE Setup**: Configured Vim with plugins for modern development
- **Shell Enhancements**: Curated bash aliases and functions for productivity
- **Language Support**: Python, Go, Node.js, LaTeX environments
- **Container Tools**: Docker and Docker Compose automation

### 💾 System Utilities
- **Backup Solutions**: Full and incremental backup scripts with automated rotation
- **GPU Tools**: Intel Iris Xe Graphics monitoring and Ollama AI integration
- **System Monitoring**: Hardware info, disk usage analysis, and cleanup utilities
- **Cloud Tools**: Cloud-init and VM provisioning scripts

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/micrometre/dotfiles.git ~/repos/dotfiles
cd ~/repos/dotfiles

# Install minimal Ansible dependencies (ansible, make, git, python3-apt, etc.)
./scripts/install_ansible.sh

# Run complete system setup via Makefile or ansible-playbook
cd ansible-local
make configure
# Or directly:
ansible-playbook playbooks/configure.yml

# Run specific roles using Makefile targets or tags
make configure_docker
make configure_python
make configure_dotfiles
# Or with tags:
ansible-playbook playbooks/configure.yml --tags "docker,python"
```

## 📁 Directory Structure

```
dotfiles/
├── ansible-local/                  # Ansible automation playbooks & roles
│   ├── playbooks/
│   │   └── configure.yml           # Master playbook configuring bare-metal/local host
│   ├── inventory/
│   │   ├── hosts.yml               # Localhost inventory definition
│   │   └── created_vms.yml         # Auto-generated inventory of provisioned VMs
│   ├── group_vars/
│   │   └── all.yml                 # Global variables
│   ├── ansible.cfg                 # Ansible configuration
│   ├── Makefile                    # Convenient targets for configure, uninstall, and VMs
│   └── roles/                      # Modular role definitions
│       ├── android-dev/            # Android SDK, cmdline-tools, KVM & USB udev rules
│       ├── android-studio/         # Android Studio installation
│       ├── common/                 # Base system packages & apt upgrades
│       ├── dart-flutter/           # Dart & Flutter SDK via Snap
│       ├── docker/                 # Docker Engine & Docker Compose
│       ├── dotfiles/               # Dotfiles (.bashrc, .vimrc, .tmux.conf) & Vundle setup
│       ├── fail2ban/               # Intrusion prevention
│       ├── golang/                 # Go development environment
│       ├── hostname/               # Hostname configuration
│       ├── latex/                  # TeX Live, latexmk, evince, vprerex
│       ├── multipass/              # Canonical Multipass setup
│       ├── nginx/                  # Nginx web server
│       ├── nodejs/                 # Node.js via NVM
│       ├── python/                 # Python (Deadsnakes PPA), venv & pip
│       ├── ssh/                    # SSH security hardening
│       ├── users/                  # User account management
│       ├── virtualization/         # KVM/QEMU/libvirt setup
│       └── vm-manager/             # Cloud-init VM creation, status & lifecycle management
│
├── backup-restore/                 # System backup & VM conversion solutions
│   ├── cleanup-before-backup.sh    # Pre-backup cache & log cleanup
│   ├── full-system-backup.sh       # Complete system backup
│   ├── incremental-backup.sh       # Incremental snapshot backups
│   ├── restore-backup.sh           # Interactive & CLI restore utility
│   ├── backup-to-vm-image.sh       # Bootable VM disk image creator
│   ├── backup-to-data-disk.sh      # Non-bootable VM data disk creator
│   └── README.md                   # Detailed backup & VM documentation
│
├── files/                          # Dotfiles and configurations
│   ├── .bash_aliases               # Curated shell aliases & functions
│   ├── .vimrc                      # Vim configuration with Vundle plugins
│   ├── .tmux.conf                  # Tmux configuration
│   └── .inputrc                    # Readline configuration
│
└── scripts/                        # Standalone bootstrap & utility scripts
    ├── install_ansible.sh          # Installs Ansible, make, and minimal prerequisites
    ├── install_latex.sh            # Standalone LaTeX installation script
    └── .cleanup.sh                 # System cleanup utility (--dry-run / --yes)
```

## 🤖 Ansible Automation

### Available Roles in `playbooks/configure.yml`

| Role | Description | Tag | Makefile Install Target | Makefile Uninstall Target |
|------|-------------|-----|-------------------------|---------------------------|
| **common** | Base system packages & apt upgrade | `common` | `make configure_update_upgrade` | — |
| **docker** | Docker & Docker Compose | `docker` | `make configure_docker` | `make uninstall_docker` |
| **nodejs** | Node.js via NVM | `nodejs` | `make configure_nodejs` | `make uninstall_nodejs` |
| **python** | Python 3.12+ with venv & pip | `python` | `make configure_python` | `make uninstall_python` |
| **dotfiles** | Deploy dotfiles & Vim plugins | `dotfiles` | `make configure_dotfiles` | `make uninstall_dotfiles` |
| **virtualization** | KVM/QEMU/libvirt setup | `virtualization` | `make configure_virtualization` | — |
| **vm-manager** | VM manager setup & VM creation | `vm-manager`, `create-vm` | `make configure_vm_manager`, `make create_vm` | `make clean`, `make clean_all` |
| **android-dev** | Android SDK, Java 17, KVM & udev rules | `android-dev` | `make configure_android_dev` | `make uninstall_android_dev` |
| **android-studio** | Android Studio IDE | `android-studio` | `make configure_android_studio` | `make uninstall_android_studio` |
| **dart-flutter** | Dart & Flutter SDK via Snap | `dart-flutter` | `make configure_dart_flutter` | `make uninstall_dart_flutter` |
| **latex** | LaTeX (`texlive-base`, `latexmk`, `evince`) | `latex` | `make configure_latex` | `make uninstall_latex` |

*(Additional standalone roles available in `ansible-local/roles/`: `golang`, `nginx`, `ssh`, `fail2ban`, `users`, `hostname`, `multipass`.)*

### Running Playbooks

```bash
cd ansible-local

# View all available Makefile commands
make help

# Run full system setup
make configure
# Or directly with ansible-playbook:
ansible-playbook playbooks/configure.yml

# Run specific roles via Makefile shortcuts
make configure_docker
make configure_python
make configure_nodejs
make configure_dotfiles
make configure_android_dev
make configure_android_studio
make configure_dart_flutter
make configure_latex
make configure_virtualization
make configure_vm_manager

# Or run specific roles by tag
ansible-playbook playbooks/configure.yml --tags "docker,python,latex"

# Uninstall specific components
make uninstall_nodejs
make uninstall_python
make uninstall_dotfiles
make uninstall_docker
make uninstall_android_dev
make uninstall_android_studio
make uninstall_dart_flutter
make uninstall_latex

# VM lifecycle management
make create_vm                          # Create default VM (hal9000)
make create_vm VM_NAME=my-server        # Create named VM
make vm_status                          # Check VM status
make workspace                          # Show VM workspace overview
make clean VM_NAME=my-server            # Clean up a specific VM
make clean_all                          # Remove all VM images and workspace
```

### Customizing Variables

Edit `ansible-local/group_vars/all.yml` or role defaults in `ansible-local/roles/<role>/defaults/main.yml`:

```yaml
# Example custom variables
vm_name: my-server
vm_ram: 4096
vm_vcpus: 2
vm_disk_size: 20G

python_version: "3.12"
```

## ⚙️ Configuration Files

### Vim Configuration

Installed via the `dotfiles` Ansible role (`make configure_dotfiles`) or manually via `files/.vimrc`:
- Syntax highlighting, line numbers, relative numbering, and auto-indentation
- Vundle plugin manager (`~/.vim/bundle/Vundle.vim`)
- Included plugins: `nerdtree`, `vim-airline`, `vim-fugitive`, `vim-gitgutter`, `fzf`, `fzf.vim`, `ale`, `vim-surround`, `vim-commentary`, `editorconfig-vim`, `vimtex`

```bash
# Automated setup (copies dotfiles, clones Vundle, and installs plugins)
cd ansible-local && make configure_dotfiles

# Or manually
cp files/.vimrc ~/
vim +PluginInstall +qall
```

### Tmux Configuration

Features split-pane management, custom key bindings, and status bar customization.

```bash
cp files/.tmux.conf ~/
tmux source-file ~/.tmux.conf
```

### Bash Aliases

100+ carefully curated aliases and functions for:
- **Git workflows**: `commit_repo`, `commit_reset`
- **Docker management**: `docker_nuke`
- **System monitoring**: `gpu-info`, `hardware_summary`, `disk_analyzer`
- **File searching**: `largest-files`, `find_files_larger_than`

```bash
cp files/.bash_aliases ~/
source ~/.bash_aliases
```

**VM Management** (via Ansible)
```bash
cd ansible-local
make create_vm VM_NAME=my-server
# Or with custom parameters:
ansible-playbook playbooks/configure.yml --tags create-vm -e "vm_name=my-server vm_ram=4096"
```

## 🛠️ Utility Scripts

Located in `scripts/`:
- **[`install_ansible.sh`](scripts/install_ansible.sh)**: Installs minimal prerequisites (`ansible`, `make`, `git`, `python3-apt`, `python3-pip`, `software-properties-common`, `curl`, `gnupg`, `openssh-client`) so `ansible-local` playbooks and `Makefile` targets work out of the box.
- **[`install_latex.sh`](scripts/install_latex.sh)**: Standalone script to install TeX Live (`texlive-base`, `texlive-lang-english`), `latexmk`, `evince`, and `vprerex` (also integrated as the `latex` Ansible role via `make configure_latex`).
- **[`.cleanup.sh`](scripts/.cleanup.sh)**: System cleanup script supporting `--dry-run` (preview mode) and `--yes` (non-interactive execution) to clean APT caches, Snap/Docker/user caches, logs, and temporary files.


## 💾 System Backup & Restore

Comprehensive backup and VM image conversion suite based on Ubuntu's official documentation.

### Quick Start

```bash
cd backup-restore

# Clean caches, temporary files, and old logs before backing up
sudo ./cleanup-before-backup.sh

# Create full system backup
sudo ./full-system-backup.sh

# Create incremental backup (snapshot-based)
sudo ./incremental-backup.sh

# List available backups
sudo ./restore-backup.sh --list

# Restore a file to test location
sudo ./restore-backup.sh --restore-file /mnt/backup/hostname-Monday-2026-11-10_02-00-00.tar.gz /etc/fstab /tmp

# Convert a backup archive into a bootable VM disk image (.img)
sudo ./backup-to-vm-image.sh

# Convert a backup archive into a non-bootable VM data disk (-data.img)
sudo ./backup-to-data-disk.sh
```

### Scripts & Features

- **[`cleanup-before-backup.sh`](backup-restore/cleanup-before-backup.sh)** (and [`scripts/.cleanup.sh`](scripts/.cleanup.sh) with `--dry-run` / `--yes`): Purges APT cache, user/system caches, thumbnails, Trash, `/tmp`, old `/var/log` files, and vacuums `journalctl` before backing up
- **[`full-system-backup.sh`](backup-restore/full-system-backup.sh)**: Complete `.tar.gz` backup of `/home`, `/etc`, `/var`, `/root`, `/boot`, `/opt`, `/usr/local`, `/srv` with 7-day automatic retention
- **[`incremental-backup.sh`](backup-restore/incremental-backup.sh)**: Uses GNU `tar` listed-incremental snapshots (`.snar`) to back up only changed files after an initial full baseline
- **[`restore-backup.sh`](backup-restore/restore-backup.sh)**: Interactive and CLI restoration (`--list`, `--contents`, `--restore-file`, `--restore-full`)
- **[`backup-to-vm-image.sh`](backup-restore/backup-to-vm-image.sh)**: Converts a `.tar.gz` backup into a bootable raw VM image with `parted`, `ext4`, generated `/etc/fstab`, and `chroot` GRUB installation (ready for QEMU/KVM `.qcow2` or VirtualBox `.vdi`)
- **[`backup-to-data-disk.sh`](backup-restore/backup-to-data-disk.sh)**: Converts a `.tar.gz` backup into a non-bootable `ext4` data disk image (`-data.img`) for mounting via loop device or attaching as a secondary VM disk (`-hdb`)

### Automation with Cron

```bash
# Edit crontab
sudo crontab -e

# Daily backup at 2 AM
0 2 * * * /home/ubuntu/repos/dotfiles/backup-restore/full-system-backup.sh

# Weekly full backup (Sunday) + daily incremental
0 3 * * 0 /home/ubuntu/repos/dotfiles/backup-restore/full-system-backup.sh
0 2 * * 1-6 /home/ubuntu/repos/dotfiles/backup-restore/incremental-backup.sh
```

See [backup-restore/README.md](backup-restore/README.md) for detailed documentation and QEMU/KVM & VirtualBox usage instructions.

## 🔍 Shell Aliases & Functions

### System Information

```bash
hardware_summary    # Complete hardware info
gpu_summary        # Detailed GPU information
system-info        # Quick system overview
laptop-model       # Laptop model name
cpu-info           # CPU details
```

### Disk Management

```bash
largest-files      # Top 10 largest files
largest-dirs       # Top 10 largest directories
disk_analyzer      # Interactive disk analysis (ncdu)
find-large         # Find files larger than 100MB
cleanup            # System cleanup dry-run preview (--dry-run)
cleanup-real       # Execute system cleanup (--yes)
cleanup_system     # Dry-run preview followed by [y/N] confirmation
```

### Docker Shortcuts

```bash
docker_nuke        # Remove all containers, images, and volumes
```

### Git Workflows

```bash
commit_repo "message"     # Git add, commit, push
commit_reset "message"    # Reset commit history
sshkey                    # Display SSH public key
```

### GPU Tools

```bash
gpu-monitor        # Real-time GPU monitoring
gpu-temp          # GPU temperature
       # Test Llama model
```



## 📦 Installation

### Prerequisites

Run the bootstrap script to install Ansible, `make`, `git`, `python3-apt`, and minimal prerequisites:

```bash
./scripts/install_ansible.sh
```

### Full Installation

```bash
# 1. Clone repository
git clone https://github.com/micrometre/dotfiles.git ~/repos/dotfiles
cd ~/repos/dotfiles

# 2. Install minimal Ansible prerequisites
./scripts/install_ansible.sh

# 3. Run Ansible playbooks (includes dotfiles & Vundle installation)
cd ansible-local
make configure

# 4. Reload shell configuration
source ~/.bashrc
```

### Selective Installation

```bash
# Install only Docker and Python
cd ansible-local
ansible-playbook playbooks/configure.yml --tags "docker,python"

# Install dotfiles and Vim plugins via Ansible
make configure_dotfiles

# Install LaTeX environment via Ansible (or standalone ./scripts/install_latex.sh)
make configure_latex

# Install Android development & Flutter environment
make configure_android_dev
make configure_android_studio
make configure_dart_flutter
```

## 📖 Usage Examples

### Setting Up a Development Workstation

```bash
# Configure Docker, Python, Node.js, and Dotfiles
cd ansible-local
ansible-playbook playbooks/configure.yml --tags "docker,python,nodejs,dotfiles"
```

### Creating a KVM Virtual Machine

```bash
# Setup virtualization and VM manager
cd ansible-local
make configure_virtualization
make configure_vm_manager

# Create a default VM (hal9000) or specify a custom name
make create_vm VM_NAME=web-server

# Or customize RAM, vCPUs, and static IP via ansible-playbook
ansible-playbook playbooks/configure.yml --tags create-vm \
  -e "vm_name=web-server" \
  -e "vm_ram=4096" \
  -e "vm_vcpus=2" \
  -e "vm_ip_config.mode=static" \
  -e "vm_ip_config.static_ip=192.168.122.100"

# Check VM status and workspace overview
make vm_status
make workspace
```

### Automated System Backup

```bash
# Setup automated daily backups
sudo crontab -e

# Add this line for 2 AM daily backups
0 2 * * * /home/ubuntu/repos/dotfiles/backup-restore/full-system-backup.sh
```

## 📋 Requirements

### System Requirements
- **OS**: Ubuntu 20.04+ or Debian 11+
- **Architecture**: x86_64 (amd64)
- **RAM**: 2GB minimum (4GB+ recommended for VM management)
- **Disk**: 20GB free space minimum

### Software Dependencies
- **Ansible**: 2.9+ (installed via `./scripts/install_ansible.sh`)
- **Make**: GNU Make
- **Python**: 3.8+ (`python3-apt`, `python3-pip`)
- **Bash**: 4.0+
- **Git**: 2.0+

### Optional Dependencies
- **Docker**: For containerization roles
- **KVM/QEMU**: For virtualization roles
- **Nginx**: For web server roles



## 📄 License

MIT License - feel free to use and modify for your own purposes.

## 👤 Author

**micrometre**
- GitHub: [@micrometre](https://github.com/micrometre)
- Repository: [dotfiles](https://github.com/micrometre/dotfiles)

## 🙏 Acknowledgments

- Ubuntu backup scripts based on [official Ubuntu documentation](https://documentation.ubuntu.com/server/how-to/backups/)
- Ansible best practices from [Ansible Galaxy](https://galaxy.ansible.com/)
- Community contributions and feedback

## 📚 Additional Resources

- [Ansible Documentation](https://docs.ansible.com/)
- [Ubuntu Server Guide](https://ubuntu.com/server/docs)
- [Vim Documentation](https://www.vim.org/docs.php)
- [Tmux Manual](https://github.com/tmux/tmux/wiki)
- [Docker Documentation](https://docs.docker.com/)
- [KVM/libvirt Guide](https://www.linux-kvm.org/)

---

**⭐ If you find this repository useful, please consider giving it a star!**

