#!/bin/bash
# ==============================================================================
# Complete Google Antigravity Suite Automated Installer for Ubuntu 26.04
# Installs: Antigravity SDK, Antigravity 2.0 Manager, and Antigravity IDE
# Zero manual browser downloads required.
# ==============================================================================

# Exit immediately if any command fails
set -e

echo "🚀 Initiating hands-off Google Antigravity Suite installation..."
echo "----------------------------------------------------------------"

# 1. Update and install core system utilities
echo "🔄 Updating system package repositories..."
sudo apt update && sudo apt upgrade -y

echo "📦 Installing underlying tool prerequisites..."
sudo apt install -y curl gpg python3-pip python3-venv desktop-file-utils

# 2. Install the Antigravity Python SDK globally
echo "🐍 Deploying Antigravity Python SDK..."
# --break-system-packages overrides PEP 668 to allow a global agent runner binary
python3 -m pip install google-antigravity --break-system-packages

# 3. Configure Google's official APT Repository
echo "🔑 Importing Google Antigravity repository signing key..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg | \
sudo gpg --dearmor --yes -o /etc/apt/keyrings/antigravity-repo-key.gpg

echo "📝 Registering the Antigravity package source channel..."
sudo sh -c 'echo "deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main" > /etc/apt/sources.list.d/google_antigravity.list'

# 4. Install the Desktop surfaces via APT
echo "🔄 Refreshing repository lists with new Google channel..."
sudo apt update

echo "🖥️ Checking available packages from Antigravity repository..."
# List all available packages to see what's actually in the repo
apt-cache search antigravity || echo "⚠️  No packages found matching 'antigravity'"

echo ""
echo "📋 Available packages in Antigravity repository:"
apt-cache policy | grep antigravity -A 2 || echo "⚠️  Repository not configured"

echo ""
echo "🖥️ Installing Antigravity 2.0 Manager..."
# Try to install just the main package first
if sudo apt install -y antigravity; then
    echo "✅ Antigravity 2.0 Manager installed successfully"
else
    echo "❌ Failed to install antigravity - package may not exist"
    echo "📦 Attempting to list all available antigravity-* packages:"
    apt-cache search --names-only '^antigravity'
fi

echo ""
echo "🖥️ Attempting to install Antigravity IDE..."
# Try to install the IDE separately with better error handling
if sudo apt install -y antigravity-ide; then
    echo "✅ Antigravity IDE installed successfully"
else
    echo "⚠️  antigravity-ide not available - skipping"
    echo "📦 Available IDE packages might be:"
    apt-cache search --names-only 'antigravity.*ide'
fi

echo "----------------------------------------------------------------"
echo "🎉 Installation Complete!"
echo "----------------------------------------------------------------"
echo "• Antigravity SDK   -> Accessible programmatically via Python (`import google.antigravity`)"
echo "• Antigravity 2.0   -> Available if installed successfully"
echo "• Antigravity IDE   -> Available if installed successfully"
echo "================================================================"