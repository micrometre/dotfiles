#!/usr/bin/bash
set -euo pipefail

# =============================================================================
# Android Development Environment Setup Script for Ubuntu
# =============================================================================
# This script installs and configures all dependencies needed for Android
# development on Ubuntu (after Android Studio is installed via snap).
#
# Usage: ./setup_android_dev.sh
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANDROID_SDK_DIR="$HOME/Android/Sdk"
CMDLINE_TOOLS_DIR="$ANDROID_SDK_DIR/cmdline-tools"
PROFILE_FILE="$HOME/.profile"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info()  { echo -e "${BLUE}[INFO]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ---------------------------------------------------------------------------
# Helper: append to profile if not already present
# ---------------------------------------------------------------------------
append_to_profile() {
    local line="$1"
    if ! grep -Fxq "$line" "$PROFILE_FILE" 2>/dev/null; then
        echo "$line" >> "$PROFILE_FILE"
        log_info "Appended to $PROFILE_FILE: $line"
    else
        log_warn "Already in profile: $line"
    fi
}

# ---------------------------------------------------------------------------
# 1. Update system & install base dependencies
# ---------------------------------------------------------------------------
log_info "Updating package lists..."
sudo apt-get update

log_info "Installing base dependencies..."
sudo apt-get install -y \
    curl \
    wget \
    git \
    unzip \
    zip \
    openjdk-17-jdk \
    openjdk-17-jre \
    libglu1-mesa \
    libpulse0 \
    libasound2t64 \
    libfontconfig1 \
    libxrender1 \
    libxtst6 \
    libxi6 \
    libfreetype6 \
    libxft2 \
    libxrandr2 \
    libxss1 \
    libxcursor1 \
    libxfixes3 \
    libxdamage1 \
    libxcomposite1 \
    libgtk-3-0 \
    libnss3 \
    libgbm1 \
    libvirt-daemon-system \
    libvirt-clients \
    bridge-utils \
    cmake \
    ninja-build \
    pkg-config \
    libblkid-dev \
    liblzma-dev

log_ok "Base dependencies installed."

# ---------------------------------------------------------------------------
# 1.5. Kotlin and Gradle
# ---------------------------------------------------------------------------
log_info "Installing Kotlin and Gradle via snap..."
sudo snap install kotlin --classic || log_warn "Kotlin snap install failed"
sudo snap install gradle --classic || log_warn "Gradle snap install failed"
log_ok "Kotlin and Gradle installed."

# Ensure Java 17 is the default
log_info "Setting Java 17 as default..."
sudo update-alternatives --set java /usr/lib/jvm/java-17-openjdk-amd64/bin/java || true
sudo update-alternatives --set javac /usr/lib/jvm/java-17-openjdk-amd64/bin/javac || true


# ---------------------------------------------------------------------------
# 2. KVM / Emulator acceleration
# ---------------------------------------------------------------------------
log_info "Setting up KVM acceleration..."
if ! groups | grep -qw kvm; then
    sudo usermod -aG kvm "$USER"
    sudo usermod -aG libvirt "$USER"
    log_warn "Added user to kvm and libvirt groups. LOG OUT & BACK IN for this to take effect."
else
    log_ok "User already in kvm group."
fi

if [ ! -f /etc/udev/rules.d/99-kvm.rules ]; then
    echo 'SUBSYSTEM=="misc", KERNEL=="kvm", GROUP="kvm", MODE="0660"' | sudo tee /etc/udev/rules.d/99-kvm.rules >/dev/null
    sudo udevadm control --reload-rules
    sudo udevadm trigger
    log_ok "KVM udev rules configured."
else
    log_ok "KVM udev rules already present."
fi

# ---------------------------------------------------------------------------
# 3. Android SDK Command Line Tools
# ---------------------------------------------------------------------------
log_info "Setting up Android SDK command line tools..."

if [ -d "$CMDLINE_TOOLS_DIR/latest" ]; then
    log_ok "Command line tools already installed."
else
    mkdir -p "$CMDLINE_TOOLS_DIR"
    cd "$CMDLINE_TOOLS_DIR"

    CMDLINE_ZIP="commandlinetools-linux-11076708_latest.zip"
    CMDLINE_URL="https://dl.google.com/android/repository/$CMDLINE_ZIP"

    log_info "Downloading command line tools..."
    wget -q --show-progress "$CMDLINE_URL" -O "$CMDLINE_ZIP"
    unzip -q "$CMDLINE_ZIP"
    rm "$CMDLINE_ZIP"
    mv cmdline-tools latest
    cd "$SCRIPT_DIR"
    log_ok "Command line tools installed to $CMDLINE_TOOLS_DIR/latest"
fi

# ---------------------------------------------------------------------------
# 4. SDK Platforms, Build Tools, Platform Tools
# ---------------------------------------------------------------------------
log_info "Installing core SDK components..."

export ANDROID_HOME="$ANDROID_SDK_DIR"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"

yes | sdkmanager --licenses >/dev/null 2>&1 || true

sdkmanager \
    "platform-tools" \
    "platforms;android-35" \
    "platforms;android-34" \
    "build-tools;35.0.0" \
    "build-tools;34.0.0" \
    "emulator" \
    "system-images;android-35;google_apis;x86_64"

log_ok "Core SDK components installed."

# ---------------------------------------------------------------------------
# 5. Environment variables
# ---------------------------------------------------------------------------
log_info "Configuring environment variables..."

append_to_profile "# Android SDK"
append_to_profile "export ANDROID_HOME=\$HOME/Android/Sdk"
append_to_profile 'export PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$PATH'
append_to_profile 'export PATH=$ANDROID_HOME/platform-tools:$PATH'
append_to_profile 'export PATH=$ANDROID_HOME/emulator:$PATH'
append_to_profile 'export PATH=$ANDROID_HOME/build-tools/35.0.0:$PATH'
append_to_profile "export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64"
append_to_profile 'export PATH=$JAVA_HOME/bin:$PATH'

log_ok "Environment variables written to $PROFILE_FILE"

# ---------------------------------------------------------------------------
# 6. USB debugging udev rules (common vendors)
# ---------------------------------------------------------------------------
log_info "Setting up USB debugging udev rules..."

UDEV_RULES="/etc/udev/rules.d/51-android.rules"
if [ ! -f "$UDEV_RULES" ]; then
    sudo tee "$UDEV_RULES" >/dev/null <<'EOF'
# ADB USB Vendors
SUBSYSTEM=="usb", ATTR{idVendor}=="0502", MODE="0666", GROUP="plugdev" # Acer
SUBSYSTEM=="usb", ATTR{idVendor}=="0b05", MODE="0666", GROUP="plugdev" # ASUS
SUBSYSTEM=="usb", ATTR{idVendor}=="413c", MODE="0666", GROUP="plugdev" # Dell
SUBSYSTEM=="usb", ATTR{idVendor}=="283b", MODE="0666", GROUP="plugdev" # Essential
SUBSYSTEM=="usb", ATTR{idVendor}=="0489", MODE="0666", GROUP="plugdev" # Foxconn
SUBSYSTEM=="usb", ATTR{idVendor}=="04b8", MODE="0666", GROUP="plugdev" # Fujitsu
SUBSYSTEM=="usb", ATTR{idVendor}=="091e", MODE="0666", GROUP="plugdev" # Garmin-Asus
SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", MODE="0666", GROUP="plugdev" # Google
SUBSYSTEM=="usb", ATTR{idVendor}=="201e", MODE="0666", GROUP="plugdev" # Haier
SUBSYSTEM=="usb", ATTR{idVendor}=="109b", MODE="0666", GROUP="plugdev" # Hisense
SUBSYSTEM=="usb", ATTR{idVendor}=="0bb4", MODE="0666", GROUP="plugdev" # HTC
SUBSYSTEM=="usb", ATTR{idVendor}=="12d1", MODE="0666", GROUP="plugdev" # Huawei
SUBSYSTEM=="usb", ATTR{idVendor}=="24e3", MODE="0666", GROUP="plugdev" # K-Touch
SUBSYSTEM=="usb", ATTR{idVendor}=="2116", MODE="0666", GROUP="plugdev" # KT-Tech
SUBSYSTEM=="usb", ATTR{idVendor}=="0482", MODE="0666", GROUP="plugdev" # Kyocera
SUBSYSTEM=="usb", ATTR{idVendor}=="17ef", MODE="0666", GROUP="plugdev" # Lenovo
SUBSYSTEM=="usb", ATTR{idVendor}=="1004", MODE="0666", GROUP="plugdev" # LG
SUBSYSTEM=="usb", ATTR{idVendor}=="22b8", MODE="0666", GROUP="plugdev" # Motorola
SUBSYSTEM=="usb", ATTR{idVendor}=="0409", MODE="0666", GROUP="plugdev" # NEC
SUBSYSTEM=="usb", ATTR{idVendor}=="2080", MODE="0666", GROUP="plugdev" # Nook
SUBSYSTEM=="usb", ATTR{idVendor}=="0955", MODE="0666", GROUP="plugdev" # Nvidia
SUBSYSTEM=="usb", ATTR{idVendor}=="2257", MODE="0666", GROUP="plugdev" # OTGV
SUBSYSTEM=="usb", ATTR{idVendor}=="10a9", MODE="0666", GROUP="plugdev" # Pantech
SUBSYSTEM=="usb", ATTR{idVendor}=="1d4d", MODE="0666", GROUP="plugdev" # Pegatron
SUBSYSTEM=="usb", ATTR{idVendor}=="0471", MODE="0666", GROUP="plugdev" # Philips
SUBSYSTEM=="usb", ATTR{idVendor}=="04da", MODE="0666", GROUP="plugdev" # PMC-Sierra
SUBSYSTEM=="usb", ATTR{idVendor}=="05c6", MODE="0666", GROUP="plugdev" # Qualcomm
SUBSYSTEM=="usb", ATTR{idVendor}=="1f53", MODE="0666", GROUP="plugdev" # SK Telesys
SUBSYSTEM=="usb", ATTR{idVendor}=="04e8", MODE="0666", GROUP="plugdev" # Samsung
SUBSYSTEM=="usb", ATTR{idVendor}=="04dd", MODE="0666", GROUP="plugdev" # Sharp
SUBSYSTEM=="usb", ATTR{idVendor}=="0fce", MODE="0666", GROUP="plugdev" # Sony Ericsson
SUBSYSTEM=="usb", ATTR{idVendor}=="1d91", MODE="0666", GROUP="plugdev" # Sony Mobile
SUBSYSTEM=="usb", ATTR{idVendor}=="2340", MODE="0666", GROUP="plugdev" # Teleepoch
SUBSYSTEM=="usb", ATTR{idVendor}=="1bbb", MODE="0666", GROUP="plugdev" # Vizio
SUBSYSTEM=="usb", ATTR{idVendor}=="19d2", MODE="0666", GROUP="plugdev" # ZTE
EOF
    sudo chmod a+r "$UDEV_RULES"
    sudo udevadm control --reload-rules
    sudo udevadm trigger
    log_ok "USB udev rules installed."
else
    log_ok "USB udev rules already present."
fi

sudo usermod -aG plugdev "$USER" 2>/dev/null || true

# ---------------------------------------------------------------------------
# 7. Verification
# ---------------------------------------------------------------------------
log_info "Running verification..."

echo ""
echo "=== Verification ==="
echo ""

printf "%-30s" "Java version:"
java -version 2>&1 | head -n 1 || log_warn "Java not found in PATH"

printf "%-30s" "ADB version:"
"$ANDROID_SDK_DIR/platform-tools/adb" version 2>/dev/null | head -n 1 || log_warn "ADB not found"

printf "%-30s" "SDK Manager:"
"$ANDROID_SDK_DIR/cmdline-tools/latest/bin/sdkmanager" --version 2>/dev/null || log_warn "sdkmanager not found"

printf "%-30s" "Emulator:"
if [ -f "$ANDROID_SDK_DIR/emulator/emulator" ]; then
    echo "$ANDROID_SDK_DIR/emulator/emulator"
else
    log_warn "emulator binary not found"
fi

echo ""
log_ok "Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Run: source $PROFILE_FILE  (or open a new terminal)"
echo "  2. Launch Android Studio:  snap run android-studio"
echo "  3. Create an AVD via Android Studio or: avdmanager create avd ..."
echo ""
log_warn "If KVM group was just added, LOG OUT and LOG BACK IN for emulator acceleration."