#A HTTP/1.1 benchmarking tool written in node,
alias bench_http='npx autocannon'

#serve static html localhost
alias serve='npx serve'

#Markdown preview with live update.
alias mkd-preview='npx markdown-preview'

#Command line interface for testing internet bandwidth using speedtest.net
alias speed-test='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -'
#git commit/push

#get wpa key
alias get_wpa='sudo grep -r '^psk=' /etc/NetworkManager/system-connections/'

#display ssh public key
alias sshkey='cat ~/.ssh/id_rsa.pub'

#pass your 3 arguments like this example! bash git-commit.sh finished updatig configs
commit_repo ()
{
commit_message1="$1"
commit_message2="$2"
commit_message3="$3"
commit_message3="$4"
commit_message3="$5"
git add . -A
git commit -m "$commit_message1 $commit_message2 $commit_message3 $commit_message4 $commit_message5"
git push
}

#reset commit history
commit_reset()
{
commit_message1="$1"
commit_message2="$2"
commit_message3="$3"
commit_message3="$4"
commit_message3="$5"
git checkout --orphan TEMP_BRANCH
git add -A
git commit -am "$commit_message1 $commit_message2 $commit_message3 $commit_message4 $commit_message5"
git branch -D master
git branch -m master
git push -f origin master
git push --set-upstream origin master
}

#delete clear docker images, volumes and containers
docker_nuke () {
docker rm -f $(docker ps -a -q)
docker rmi -f $(docker images -q)
docker volume prune
docker network prune
docker volume ls -q | xargs -r docker volume rm -f
}

# System cleanup 
alias cleanup='sudo /home/ubuntu/.cleanup.sh'

# Alternative cleanup function with confirmation
cleanup_system() {
    echo "Running system cleanup ..."
    sudo /home/ubuntu/.cleanup.sh
}

# Find largest files and directories
# Show top 10 largest files in current directory (recursive)
alias largest-files='find . -type f -exec du -h {} + 2>/dev/null | sort -rh | head -10'

# Show top 10 largest directories in current directory
alias largest-dirs='du -h --max-depth=1 2>/dev/null | sort -rh | head -10'

# Show top 20 largest files system-wide (requires sudo for full access)
alias largest-files-system='sudo find / -type f -exec du -h {} + 2>/dev/null | sort -rh | head -20'

# Show disk usage of directories in current path, sorted by size
alias disk-usage='du -h --max-depth=1 | sort -rh'

# Find large files over 100MB in current directory
alias find-large='find . -type f -size +100M -exec du -h {} + 2>/dev/null | sort -rh'

# Interactive function to find largest files with custom size
find_files_larger_than() {
    if [ -z "$1" ]; then
        echo "Usage: find_files_larger_than <size>"
        echo "Example: find_files_larger_than 50M"
        echo "Example: find_files_larger_than 1G"
        return 1
    fi
    find . -type f -size +$1 -exec du -h {} + 2>/dev/null | sort -rh
}

# Show directory sizes with ncdu if available, fallback to du
disk_analyzer() {
    if command -v ncdu &> /dev/null; then
        echo "Using ncdu for interactive disk analysis..."
        ncdu
    else
        echo "ncdu not found, using du instead..."
        echo "Install ncdu for better disk analysis: sudo apt install ncdu"
        du -h --max-depth=2 | sort -rh | head -20
    fi
}

# System Information Commands
# Get laptop model and manufacturer
alias laptop-model='sudo dmidecode -s system-product-name'
alias laptop-manufacturer='sudo dmidecode -s system-manufacturer'
alias laptop-serial='sudo dmidecode -s system-serial-number'

# Complete system info
alias system-info='echo "=== System Information ===" && echo "Manufacturer: $(sudo dmidecode -s system-manufacturer)" && echo "Model: $(sudo dmidecode -s system-product-name)" && echo "Serial: $(sudo dmidecode -s system-serial-number)" && echo "BIOS: $(sudo dmidecode -s bios-version)"'

# Alternative methods for system info
alias hw-info='lshw -short'
alias laptop-info='inxi -M'  # requires inxi package
alias cpu-info='lscpu | grep "Model name"'

# Comprehensive hardware summary
hardware_summary() {
    echo "========================================="
    echo "Hardware Information Summary"
    echo "========================================="
    echo "Manufacturer: $(sudo dmidecode -s system-manufacturer 2>/dev/null || echo 'Unknown')"
    echo "Model: $(sudo dmidecode -s system-product-name 2>/dev/null || echo 'Unknown')"
    echo "Serial Number: $(sudo dmidecode -s system-serial-number 2>/dev/null || echo 'Unknown')"
    echo "BIOS Version: $(sudo dmidecode -s bios-version 2>/dev/null || echo 'Unknown')"
    echo ""
    echo "CPU: $(lscpu | grep 'Model name' | cut -d':' -f2 | sed 's/^ *//')"
    echo "Memory: $(free -h | grep 'Mem:' | awk '{print $2}')"
    echo "Disk: $(df -h / | tail -1 | awk '{print $2}')"
    echo "Kernel: $(uname -r)"
    echo "OS: $(lsb_release -d 2>/dev/null | cut -d':' -f2 | sed 's/^ *//' || cat /etc/os-release | grep PRETTY_NAME | cut -d'=' -f2 | tr -d '"')"
    echo "========================================="
}

# GPU Information Commands
# Show GPU information
alias gpu-info='lspci | grep -i vga'
alias gpu-details='lspci -v | grep -A 12 VGA'
alias gpu-nvidia='nvidia-smi 2>/dev/null || echo "NVIDIA drivers not installed or no NVIDIA GPU found"'
alias gpu-all='lspci | grep -i "vga\|3d\|display"'

# Get GPU driver information
alias gpu-driver='lsmod | grep -i "nvidia\|radeon\|i915\|amdgpu"'
alias gpu-glx='glxinfo | grep "OpenGL renderer" 2>/dev/null || echo "Install mesa-utils: sudo apt install mesa-utils"'

# Comprehensive GPU information
gpu_summary() {
    echo "========================================="
    echo "GPU Information Summary"
    echo "========================================="
    echo "Graphics Cards:"
    lspci | grep -i "vga\|3d\|display"
    echo ""
    
    echo "Loaded GPU Drivers:"
    lsmod | grep -i "nvidia\|radeon\|i915\|amdgpu" || echo "No common GPU drivers loaded"
    echo ""
    
    if command -v nvidia-smi &> /dev/null; then
        echo "NVIDIA GPU Status:"
        nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader,nounits 2>/dev/null
        echo ""
    fi
    
    if command -v glxinfo &> /dev/null; then
        echo "OpenGL Renderer:"
        glxinfo | grep "OpenGL renderer"
        echo "OpenGL Version:"
        glxinfo | grep "OpenGL version"
    else
        echo "Install mesa-utils for OpenGL info: sudo apt install mesa-utils"
    fi
    echo "========================================="
}
