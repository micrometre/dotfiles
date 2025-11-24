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
git clone https://github.com/micrometre/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Install Ansible (if not already installed)
sudo apt update && sudo apt install -y ansible

# Run complete system setup
cd ansible-local
ansible-playbook main.yml --ask-become-pass

# Or run specific roles with tags
ansible-playbook main.yml --tags "setup_docker,setup_python" --ask-become-pass

# Copy dotfiles to your home directory
cp files/.bash_aliases ~/
cp files/.vimrc ~/
cp files/.tmux.conf ~/
source ~/.bashrc
```

## 📁 Directory Structure

```
dotfiles/
├── ansible-local/          # Ansible automation playbooks
│   ├── main.yml           # Master playbook with all roles
│   ├── ansible.cfg        # Ansible configuration
│   ├── Makefile          # Quick commands for common tasks
│   ├── roles/            # Modular role definitions
│   │   ├── common/       # Basic system setup
│   │   ├── docker/       # Docker & Docker Compose
│   │   ├── python/       # Python 3.10+ environment
│   │   ├── golang/       # Go development setup
│   │   ├── nodejs/       # Node.js via NVM
│   │   ├── nginx/        # Nginx web server
│   │   ├── ssh/          # SSH security hardening
│   │   ├── fail2ban/     # Intrusion prevention
│   │   ├── users/        # User account management
│   │   ├── dotfiles/     # Dotfiles deployment
│   │   ├── virtualization/ # KVM/QEMU setup
│   │   └── vm-manager/   # VM creation & management
│   └── scripts/          # Helper scripts
│
├── backup-restore/         # System backup solutions
│   ├── full-system-backup.sh      # Complete system backup
│   ├── incremental-backup.sh      # Incremental backups
│   ├── restore-backup.sh          # Restore utility
│   ├── backup-to-vm-image.sh      # VM-optimized backup
│   ├── quick-vm-convert.sh        # VM image conversion
│   └── README.md                  # Detailed documentation
│
├── files/                  # Dotfiles and configurations
│   ├── .bash_aliases      # 100+ useful aliases & functions
│   ├── .vimrc            # Vim configuration with plugins
│   ├── .vimrc-v2         # Alternative Vim config
│   ├── .tmux.conf        # Tmux configuration
│   ├── .inputrc          # Readline configuration
│   └── .cleanup.sh       # System cleanup script
│
└── scripts/               # Standalone utility scripts
    ├── install_ollam.sh           # Ollama AI installation
    ├── debug_ollama_intel.sh      # Intel GPU debugging
    ├── test_ollama_gpu.sh         # GPU capability testing
    ├── install_cloudinit.sh       # Cloud-init setup
    ├── install_latex.sh           # LaTeX environment
    ├── vim_ide.sh                 # Vim IDE setup
    ├── openalpr_install.sh        # OpenALPR (ANPR) setup
    ├── make-certs-nginx.sh        # SSL certificate generation
    └── ssh-agent.sh               # SSH agent helper
```

## 🤖 Ansible Automation

### Available Roles

| Role | Description | Tag |
|------|-------------|-----|
| **virtualization** | KVM/QEMU/libvirt setup | `setup_virtualization` |
| **vm-manager** | VM creation with cloud-init | `create_vm` |
| **docker** | Docker & Docker Compose | `setup_docker` |
| **python** | Python 3.10+ with pip | `setup_python` |
| **golang** | Go development environment | `setup_golang` |
| **nodejs** | Node.js via NVM | `setup_nodejs_dotfiles` |
| **nginx** | Nginx web server | `setup_nginx` |
| **ssh** | SSH security hardening | `setup_ssh` |
| **fail2ban** | Intrusion prevention | `setup_fail2ban` |
| **users** | User account management | `setup_users` |
| **dotfiles** | Deploy dotfiles | `setup_dotfiles` |
| **common** | Basic system packages | `setup_common` |

### Running Playbooks

```bash
cd ansible-local

# Run all playbooks (full system setup)
ansible-playbook main.yml --ask-become-pass

# Run specific roles by tag
ansible-playbook main.yml --tags setup_docker --ask-become-pass
ansible-playbook main.yml --tags "setup_python,setup_nodejs_dotfiles" --ask-become-pass

# Create a VM
ansible-playbook main.yml --tags create_vm --ask-become-pass

# Setup virtualization environment
ansible-playbook main.yml --tags setup_virtualization --ask-become-pass

# Use Makefile shortcuts
make setup          # Run full setup
make setup-docker   # Setup Docker only
make setup-python   # Setup Python only
```

### Customizing Variables

Edit `ansible-local/group_vars/all.yml` or `ansible-local/host_vars/localhost.yml`:

```yaml
# Example custom variables
vm_name: my-server
vm_ram: 4096
vm_vcpus: 2
vm_disk_size: 20G

python_version: "3.11"
docker_users:
  - ubuntu
  - myuser

nginx_server_name: example.com
```

## ⚙️ Configuration Files

### Vim Configuration

**Features:**
- Syntax highlighting and auto-indentation
- Plugin manager ready (Vundle/Pathogen)
- Included plugins:
  - `emmet-vim` - HTML/CSS shortcuts
  - `editorconfig-vim` - EditorConfig support
  - `vimtex` - LaTeX integration
  - `vim-latex-live-preview` - Live LaTeX preview
  - `vim-airline` - Status bar
  - `syntastic` - Syntax checking
  - `vim-gitgutter` - Git diff in gutter

**Installation:**
```bash
# Use the automated script
./scripts/vim_ide.sh

# Or manually
cp files/.vimrc ~/
vim +PluginInstall +qall  # If using Vundle
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
- **Performance testing**: `bench_http`, `speed-test`
- **File searching**: `largest-files`, `find_files_larger_than`
- **GPU monitoring**: `gpu-temp`, `gpu-summary`, `ollama-gpu`
- **Development tools**: `serve`, `mkd-preview`

```bash
cp files/.bash_aliases ~/
source ~/.bash_aliases
```

## 🛠 Utility Scripts

### AI & Machine Learning

**Ollama AI Setup**
```bash
# Install Ollama with Intel GPU optimization
./scripts/install_ollam.sh

# Debug Intel GPU for Ollama
./scripts/debug_ollama_intel.sh

# Test GPU acceleration
./scripts/test_ollama_gpu.sh

# Run optimized Ollama models
ollama-gpu run phi3:mini
test-llama  # Alias for llama3.2:3b
```

**ANPR/ALPR System**
```bash
# Install OpenALPR for license plate recognition
./scripts/openalpr_install.sh       # User install
./scripts/openalpr_root-install.sh  # System-wide install
```

### Cloud & Virtualization

**Cloud-Init Setup**
```bash
./scripts/install_cloudinit.sh
```

**VM Management** (via Ansible)
```bash
cd ansible-local
ansible-playbook main.yml --tags create_vm -e "vm_name=my-server vm_ram=4096"
```

### Development Tools

**LaTeX Environment**
```bash
./scripts/install_latex.sh
```

**Nginx SSL Certificates**
```bash
./scripts/make-certs-nginx.sh
```

**SSH Agent Setup**
```bash
./scripts/ssh-agent.sh
```

## 💾 System Backup & Restore

Comprehensive backup solution based on Ubuntu's official documentation.

### Quick Start

```bash
cd backup-restore

# Create full system backup
sudo ./full-system-backup.sh

# Create incremental backup
sudo ./incremental-backup.sh

# List available backups
sudo ./restore-backup.sh --list

# Restore a file to test location
sudo ./restore-backup.sh --restore-file /mnt/backup/hostname-Monday.tar.gz /etc/fstab /tmp
```

### Features

- **Full System Backup**: Complete backup of `/home`, `/etc`, `/var`, `/root`, `/boot`, `/opt`, `/usr/local`
- **Incremental Backup**: Only backup changed files
- **Automated Rotation**: 7-day backup retention
- **Interactive Restore**: Safe restoration with testing capabilities
- **VM-Optimized Backup**: Special backup for virtual machines
- **Progress Indication**: Real-time backup status

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

See [backup-restore/README.md](backup-restore/README.md) for detailed documentation.

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
find_files_larger_than 100M  # Find files larger than 100MB
cleanup            # System cleanup script
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

### GPU & AI Tools

```bash
gpu-monitor        # Real-time GPU monitoring
gpu-temp          # GPU temperature
ollama-debug      # Debug Ollama AI
ollama-gpu        # Run Ollama with GPU optimization
test-phi3         # Test Phi3 model
test-llama        # Test Llama model
```

### Network & Performance

```bash
speed-test        # Internet speed test
bench_http        # HTTP benchmarking tool
serve             # Serve static files (npx serve)
```

## 📦 Installation

### Prerequisites

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Ansible
sudo apt install -y ansible git

# Install Python pip (if needed)
sudo apt install -y python3-pip
```

### Full Installation

```bash
# 1. Clone repository
git clone https://github.com/micrometre/dotfiles.git ~/repos/dotfiles
cd ~/repos/dotfiles

# 2. Run Ansible playbooks
cd ansible-local
ansible-playbook main.yml --ask-become-pass

# 3. Copy dotfiles
cp files/.bash_aliases ~/
cp files/.vimrc ~/
cp files/.tmux.conf ~/
cp files/.inputrc ~/

# 4. Reload shell configuration
source ~/.bashrc
```

### Selective Installation

```bash
# Install only Docker and Python
cd ansible-local
ansible-playbook main.yml --tags "setup_docker,setup_python" --ask-become-pass

# Copy only bash aliases
cp files/.bash_aliases ~/
source ~/.bash_aliases

# Setup Vim IDE only
./scripts/vim_ide.sh
```

## 📖 Usage Examples

### Setting Up a Development Server

```bash
# Full stack development server with Docker, Python, Node.js, and Nginx
cd ansible-local
ansible-playbook main.yml --tags "setup_docker,setup_python,setup_nodejs_dotfiles,setup_nginx" --ask-become-pass
```

### Creating a KVM Virtual Machine

```bash
# Setup virtualization
cd ansible-local
ansible-playbook main.yml --tags setup_virtualization --ask-become-pass

# Create VM with static IP
ansible-playbook main.yml --tags create_vm --ask-become-pass \
  -e "vm_name=web-server" \
  -e "vm_ram=4096" \
  -e "vm_vcpus=2" \
  -e "vm_ip_config.mode=static" \
  -e "vm_ip_config.static_ip=192.168.122.100"
```

### Setting Up AI Development Environment

```bash
# Install Ollama with Intel GPU support
./scripts/install_ollam.sh

# Test GPU acceleration
./scripts/test_ollama_gpu.sh

# Run models with GPU optimization
ollama-gpu run llama3.2:3b
```

### Automated System Backup

```bash
# Setup automated daily backups
sudo crontab -e

# Add this line for 2 AM daily backups
0 2 * * * /home/ubuntu/repos/dotfiles/backup-restore/full-system-backup.sh
```

### Hardening SSH Security

```bash
cd ansible-local
ansible-playbook main.yml --tags "setup_ssh,setup_fail2ban" --ask-become-pass
```

## 📋 Requirements

### System Requirements
- **OS**: Ubuntu 20.04+ or Debian 11+
- **Architecture**: x86_64 (amd64)
- **RAM**: 2GB minimum (4GB+ recommended for VM management)
- **Disk**: 20GB free space minimum

### Software Dependencies
- **Ansible**: 2.9+
- **Python**: 3.8+
- **Bash**: 4.0+
- **Git**: 2.0+

### Optional Dependencies
- **Docker**: For containerization roles
- **KVM/QEMU**: For virtualization roles
- **Nginx**: For web server roles
- **Intel GPU drivers**: For Ollama AI acceleration

## 🤝 Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for:

- Bug fixes
- New roles or scripts
- Documentation improvements
- Feature requests

### Development Setup

```bash
# Fork and clone
git clone https://github.com/YOUR_USERNAME/dotfiles.git
cd dotfiles

# Create feature branch
git checkout -b feature/my-new-feature

# Make changes and test
cd ansible-local
ansible-playbook main.yml --check --diff

# Commit and push
git add .
git commit -m "Add new feature"
git push origin feature/my-new-feature
```

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

