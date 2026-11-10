# ==============================================================================
# Directory Navigation
# ==============================================================================

alias push='pushd > /dev/null'
alias pop='popd > /dev/null'

# Replaces cd with pushd so you can always 'pop' your way backward
cd() {
    if [ -z "$1" ]; then
        pushd ~ > /dev/null || return
    else
        pushd "$1" > /dev/null || return
    fi
}


# ==============================================================================
# Network & Utilities
# ==============================================================================

# Command line interface for testing internet bandwidth using speedtest.net
alias speed-test='curl -fsSL https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -'

# ==============================================================================
# Git Helpers
# ==============================================================================

# Stage, commit, and push all changes
commit_repo() {
    # Check if we are in a git repository
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "Error: Not a git repository." >&2
        return 1
    fi

    # Check if there are any changes to commit (staged, unstaged, or untracked)
    if [ -z "$(git status --porcelain)" ]; then
        echo "No changes to commit."
        return 0
    fi

    # Fallback default message if none provided
    local commit_message="${*:-Update repository}"

    echo "--> Staging all changes..."
    git add -A || return 1

    echo "--> Committing with message: '$commit_message'..."
    git commit -m "$commit_message" || return 1

    echo "--> Pushing to remote..."
    git push || return 1

    echo "Done! 🚀"
}

# Reset commit history on the current branch (or master) to a single commit
commit_reset() {
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "Error: Not a git repository." >&2
        return 1
    fi

    local commit_message="${*:-Initial commit}"
    local branch
    branch="$(git symbolic-ref --short HEAD 2>/dev/null || echo "master")"

    git checkout --orphan TEMP_BRANCH || return 1
    git add -A || return 1
    git commit -m "$commit_message" || return 1
    git branch -D "$branch" 2>/dev/null || true
    git branch -m "$branch" || return 1
    git push -f --set-upstream origin "$branch"
}

# ==============================================================================
# Docker
# ==============================================================================

# Delete and clear all Docker containers, images, volumes, and networks
docker_nuke() {
    docker ps -aq | xargs -r docker rm -f
    docker images -q | xargs -r docker rmi -f
    docker volume ls -q | xargs -r docker volume rm -f
    docker volume prune -f
    docker network prune -f
}

# ==============================================================================
# System Cleanup & Disk Usage
# ==============================================================================

# System cleanup (preview by default)
alias cleanup='sudo "$HOME/.cleanup.sh" --dry-run'
alias cleanup-real='sudo "$HOME/.cleanup.sh" --yes'

# Alternative cleanup function with confirmation
cleanup_system() {
    local script="$HOME/.cleanup.sh"
    if [ ! -f "$script" ]; then
        echo "Error: Cleanup script not found at $script" >&2
        return 1
    fi

    echo "Running cleanup dry run first..."
    sudo "$script" --dry-run

    read -r -p "Do you want to execute the actual cleanup? [y/N] " response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo "Running system cleanup..."
        sudo "$script" --yes
    else
        echo "Cleanup cancelled."
    fi
}

# Find largest files and directories
# Show top 10 largest files in current directory (recursive)
alias largest-files='find . -type f -exec du -h {} + 2>/dev/null | sort -rh | head -n 10'

# Show top 10 largest directories in current directory
alias largest-dirs='du -h --max-depth=1 2>/dev/null | sort -rh | head -n 10'

# Show top 20 largest files system-wide (requires sudo for full access)
alias largest-files-system='sudo find / -xdev -type f -exec du -h {} + 2>/dev/null | sort -rh | head -n 20'

# Show disk usage of directories in current path, sorted by size
alias disk-usage='du -h --max-depth=1 2>/dev/null | sort -rh'

# Find large files over 100MB in current directory
alias find-large='find . -type f -size +100M -exec du -h {} + 2>/dev/null | sort -rh'

# Show directory sizes with ncdu if available, fallback to du
disk_analyzer() {
    local target="${1:-.}"
    if command -v ncdu &>/dev/null; then
        echo "Using ncdu for interactive disk analysis..."
        ncdu "$target"
    else
        echo "ncdu not found, using du instead..."
        echo "Install ncdu for better disk analysis: sudo apt install ncdu"
        du -h --max-depth=2 "$target" 2>/dev/null | sort -rh | head -n 20
    fi
}

# ==============================================================================
# System & Hardware Information
# ==============================================================================

# Get laptop model and manufacturer
alias laptop-model='sudo dmidecode -s system-product-name'
alias laptop-manufacturer='sudo dmidecode -s system-manufacturer'
alias laptop-serial='sudo dmidecode -s system-serial-number'

# Complete system info (single-quoted so sudo does not run on shell startup)
alias system-info='echo "=== System Information ===" && echo "Manufacturer: $(sudo dmidecode -s system-manufacturer)" && echo "Model: $(sudo dmidecode -s system-product-name)" && echo "Serial: $(sudo dmidecode -s system-serial-number)" && echo "BIOS: $(sudo dmidecode -s bios-version)"'

# Alternative methods for system info
alias hw-info='lshw -short'
alias laptop-info='inxi -M' # requires inxi package
alias cpu-info='lscpu | grep "Model name"'

# Comprehensive hardware summary
hardware_summary() {
    local os_name="Unknown"
    if [ -f /etc/os-release ]; then
        os_name="$(. /etc/os-release && echo "${PRETTY_NAME:-$NAME}")"
    elif command -v lsb_release &>/dev/null; then
        os_name="$(lsb_release -ds)"
    fi

    echo "========================================="
    echo "Hardware Information Summary"
    echo "========================================="
    echo "Manufacturer:  $(sudo dmidecode -s system-manufacturer 2>/dev/null || echo 'Unknown')"
    echo "Model:         $(sudo dmidecode -s system-product-name 2>/dev/null || echo 'Unknown')"
    echo "Serial Number: $(sudo dmidecode -s system-serial-number 2>/dev/null || echo 'Unknown')"
    echo "BIOS Version:  $(sudo dmidecode -s bios-version 2>/dev/null || echo 'Unknown')"
    echo ""
    echo "CPU:           $(lscpu | awk -F': +' '/Model name/ {print $2; exit}')"
    echo "Memory:        $(free -h | awk '/^Mem:/ {print $2}')"
    echo "Disk (/):      $(df -h / | awk 'NR==2 {print $2}')"
    echo "Kernel:        $(uname -r)"
    echo "OS:            $os_name"
    echo "========================================="
}

# ==============================================================================
# GPU Information & Monitoring
# ==============================================================================

# Show GPU information
alias gpu-info='lspci | grep -i vga'
alias gpu-details='lspci -v | grep -A 12 VGA'
alias gpu-nvidia='nvidia-smi 2>/dev/null || echo "NVIDIA drivers not installed or no NVIDIA GPU found"'
alias gpu-all='lspci | grep -iE "vga|3d|display"'

# Get GPU driver information
alias gpu-driver='lsmod | grep -iE "nvidia|radeon|i915|amdgpu"'
alias gpu-glx='glxinfo | grep "OpenGL renderer" 2>/dev/null || echo "Install mesa-utils: sudo apt install mesa-utils"'

# Comprehensive GPU information
gpu_summary() {
    echo "========================================="
    echo "GPU Information Summary"
    echo "========================================="
    echo "Graphics Cards:"
    lspci | grep -iE "vga|3d|display" || echo "No GPU detected via lspci"
    echo ""

    echo "Loaded GPU Drivers:"
    lsmod | grep -iE "nvidia|radeon|i915|amdgpu" || echo "No common GPU drivers loaded"
    echo ""

    if command -v nvidia-smi &>/dev/null; then
        echo "NVIDIA GPU Status:"
        nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader,nounits 2>/dev/null
        echo ""
    fi

    if command -v glxinfo &>/dev/null; then
        echo "OpenGL Info:"
        glxinfo 2>/dev/null | grep -E "OpenGL (renderer|version)"
    else
        echo "Install mesa-utils for OpenGL info: sudo apt install mesa-utils"
    fi
    echo "========================================="
}

# GPU monitoring
alias gpu-monitor='intel_gpu_top'
alias gpu-temp='sensors | grep -A 10 -E "coretemp|Package"'


