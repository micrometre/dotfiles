#!/bin/bash
####################################
#
# Ollama Installation Script
# Optimized for Intel Iris Xe GPU on Ubuntu 24.04
# Dell Latitude 7340 (0C08)
#
####################################

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Installing Ollama with Intel Iris Xe GPU support${NC}"
echo -e "${BLUE}Dell Latitude 7340 - Ubuntu 24.04${NC}"
echo ""

# Update system
echo -e "${YELLOW}Updating system packages...${NC}"
sudo apt update && sudo apt upgrade -y

# Install Intel GPU runtime packages for Ubuntu 24.04
echo -e "${YELLOW}Installing Intel GPU runtime...${NC}"

# Core OpenCL packages
sudo apt install -y intel-opencl-icd ocl-icd-opencl-dev clinfo

# Try to install Intel compute runtime packages
echo -e "${YELLOW}Installing Intel Level Zero runtime...${NC}"

# For Ubuntu 24.04, try the package from repos first
if apt-cache search intel-level-zero | grep -q level-zero; then
    sudo apt install -y intel-level-zero-gpu level-zero level-zero-dev
    echo -e "${GREEN}✓ Installed Level Zero from repository${NC}"
else
    echo -e "${YELLOW}Adding Intel's compute runtime repository...${NC}"
    
    # Add Intel's repository for newer packages
    wget -qO - https://repositories.intel.com/gpu/intel-graphics.key | sudo gpg --dearmor --output /usr/share/keyrings/intel-graphics.gpg
    echo "deb [arch=amd64,i386 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/gpu/ubuntu jammy client" | sudo tee /etc/apt/sources.list.d/intel-graphics.list
    
    sudo apt update
    
    # Install from Intel's repository
    sudo apt install -y intel-level-zero-gpu level-zero level-zero-dev intel-opencl-icd || {
        echo -e "${RED}Warning: Could not install all Intel packages${NC}"
        echo -e "${YELLOW}Continuing with basic OpenCL support${NC}"
    }
fi

# Install GPU monitoring tools
echo -e "${YELLOW}Installing GPU monitoring tools...${NC}"
sudo apt install -y intel-gpu-tools

# Add user to required groups
echo -e "${YELLOW}Adding user to render and video groups...${NC}"
sudo usermod -a -G render $USER
sudo usermod -a -G video $USER

echo -e "${YELLOW}Verifying OpenCL installation...${NC}"
clinfo | grep -i "intel\|device" || echo -e "${RED}Warning: Intel GPU not detected in OpenCL${NC}"

echo ""
echo -e "${BLUE}Installing Ollama...${NC}"
curl -fsSL https://ollama.com/install.sh | sh

# Create Ollama configuration for Intel GPU
echo -e "${YELLOW}Configuring Ollama for Intel GPU...${NC}"

# Create systemd override directory
sudo mkdir -p /etc/systemd/system/ollama.service.d

# Create environment configuration
sudo tee /etc/systemd/system/ollama.service.d/intel-gpu.conf > /dev/null << EOF
[Service]
Environment="OLLAMA_GPU_OVERRIDE=1"
Environment="ZE_AFFINITY_MASK=0"
Environment="SYCL_CACHE_PERSISTENT=1"
EOF

# Reload systemd and restart ollama
sudo systemctl daemon-reload
sudo systemctl restart ollama

echo ""
echo -e "${GREEN}Installation completed!${NC}"
echo ""
echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}Next Steps:${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""
echo -e "${YELLOW}1. Log out and back in (to apply group changes)${NC}"
echo ""
echo -e "${YELLOW}2. Verify Ollama installation:${NC}"
echo "   ollama version"
echo ""
echo -e "${YELLOW}3. Test with a small model:${NC}"
echo "   ollama run phi3:mini"
echo ""
echo -e "${YELLOW}4. Monitor GPU usage:${NC}"
echo "   intel_gpu_top"
echo ""
echo -e "${YELLOW}5. Run debug script if issues occur:${NC}"
echo "   ~/repos/dotfiles/scripts/debug_ollama_intel.sh"
echo ""
echo -e "${GREEN}For Intel Iris Xe optimization:${NC}"
echo "- Use smaller models (3B-7B parameters work best)"
echo "- Ensure laptop is plugged in for better performance"
echo "- Monitor temperature with: sensors"
echo ""

exit 0
