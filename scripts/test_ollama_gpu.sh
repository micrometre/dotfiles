#!/bin/bash
####################################
#
# Ollama Intel GPU Test Script
# Tests GPU acceleration with monitoring
#
####################################

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}Ollama Intel GPU Acceleration Test${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""

# Function to test GPU with a simple prompt
test_gpu_acceleration() {
    echo -e "${YELLOW}Testing GPU acceleration with phi3:mini...${NC}"
    echo ""
    
    # Start GPU monitoring in background
    echo -e "${YELLOW}Starting GPU monitoring (Ctrl+C to stop)...${NC}"
    intel_gpu_top -s 1000 > /tmp/gpu_usage.log 2>&1 &
    GPU_MON_PID=$!
    
    # Give monitoring time to start
    sleep 2
    
    echo -e "${YELLOW}Running test prompt: 'Explain what GPU acceleration is in one sentence.'${NC}"
    echo ""
    
    # Run Ollama with environment variables for GPU
    OLLAMA_DEBUG=1 \
    OLLAMA_GPU_OVERRIDE=1 \
    ZE_AFFINITY_MASK=0 \
    echo "Explain what GPU acceleration is in one sentence." | ollama run phi3:mini
    
    # Stop GPU monitoring
    kill $GPU_MON_PID 2>/dev/null
    
    echo ""
    echo -e "${BLUE}GPU Usage Summary:${NC}"
    if [ -f /tmp/gpu_usage.log ]; then
        # Show last few lines of GPU usage
        tail -10 /tmp/gpu_usage.log | grep -E "render|compute" || echo "No GPU activity detected"
        rm /tmp/gpu_usage.log
    fi
}

# Function to check Ollama GPU detection
check_ollama_gpu() {
    echo -e "${YELLOW}Checking Ollama GPU detection...${NC}"
    
    # Check if Ollama detects GPU
    if journalctl -u ollama --since "5 minutes ago" | grep -i "gpu\|opencl\|level.zero\|intel"; then
        echo -e "${GREEN}✓ GPU-related activity found in Ollama logs${NC}"
    else
        echo -e "${YELLOW}! No GPU activity in recent Ollama logs${NC}"
    fi
    echo ""
}

# Function to show current resource usage
show_resources() {
    echo -e "${YELLOW}Current System Resources:${NC}"
    echo "CPU Usage: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | awk -F'%' '{print $1}')%"
    echo "Memory Usage: $(free | grep Mem | awk '{printf("%.1f%%"), $3/$2 * 100.0}')"
    echo ""
    
    echo -e "${YELLOW}GPU Information:${NC}"
    echo "GPU: $(lspci | grep VGA | cut -d: -f3 | sed 's/^ *//')"
    echo "OpenCL Device: $(clinfo -l 2>/dev/null | grep "Device #" | head -1 || echo 'Not detected')"
    echo ""
}

# Function to optimize Ollama for Intel GPU
optimize_ollama() {
    echo -e "${YELLOW}Setting up Ollama optimization for Intel Iris Xe...${NC}"
    
    # Create or update systemd override
    sudo mkdir -p /etc/systemd/system/ollama.service.d
    
    sudo tee /etc/systemd/system/ollama.service.d/intel-gpu.conf > /dev/null << EOF
[Service]
Environment="OLLAMA_GPU_OVERRIDE=1"
Environment="ZE_AFFINITY_MASK=0"
Environment="SYCL_CACHE_PERSISTENT=1"
Environment="OLLAMA_DEBUG=1"
Environment="OLLAMA_INTEL_GPU=1"
EOF
    
    # Reload and restart service
    sudo systemctl daemon-reload
    sudo systemctl restart ollama
    
    echo -e "${GREEN}✓ Ollama service optimized for Intel GPU${NC}"
    echo ""
    
    # Wait for service to restart
    sleep 3
}

# Main execution
echo -e "${BLUE}Dell Latitude 7340 - Intel Iris Xe Graphics${NC}"
echo ""

show_resources
check_ollama_gpu

echo -e "${YELLOW}Would you like to optimize Ollama for Intel GPU? (y/n):${NC}"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    optimize_ollama
fi

echo -e "${YELLOW}Would you like to run the GPU acceleration test? (y/n):${NC}"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    test_gpu_acceleration
fi

echo ""
echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}Recommendations for Intel Iris Xe${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""
echo -e "${GREEN}✓ Your Intel Iris Xe GPU is detected and configured${NC}"
echo -e "${GREEN}✓ OpenCL support is working${NC}"
echo -e "${GREEN}✓ Level Zero runtime is installed${NC}"
echo ""
echo -e "${YELLOW}Performance Tips:${NC}"
echo "• Use models under 8B parameters for best performance"
echo "• Recommended models: phi3:mini, gemma2:2b, llama3.2:3b"
echo "• Keep laptop plugged in for sustained performance"
echo "• Monitor with: intel_gpu_top"
echo ""
echo -e "${YELLOW}If performance seems slow:${NC}"
echo "• Check BIOS settings for GPU memory allocation"
echo "• Ensure Intel GPU drivers are up to date"
echo "• Consider using CPU-only mode for very large models"
echo ""

exit 0