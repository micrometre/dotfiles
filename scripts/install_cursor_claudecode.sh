#!/usr/bin/env bash
# ============================================================
# install_cursor_claudecode.sh
# Installs Cursor IDE and Claude Code on Ubuntu (24.04/26.04)
# Usage: bash install_cursor_claudecode.sh
# ============================================================

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()    { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }
section() { echo -e "\n${GREEN}===== $* =====${NC}"; }

# ── Preflight ──────────────────────────────────────────────
section "Preflight checks"

[[ "$(uname -s)" == "Linux" ]] || error "This script is for Linux only."
command -v apt &>/dev/null    || error "apt not found – are you on Ubuntu/Debian?"

ARCH=$(uname -m)
info "Architecture: $ARCH"
info "User: $USER"

# ── System update ──────────────────────────────────────────
section "Updating package lists"
sudo apt update -y

# ── Dependencies ───────────────────────────────────────────
section "Installing dependencies"
sudo apt install -y \
    curl \
    wget \
    ca-certificates \
    gnupg \
    lsb-release \
    libfuse2 \
    fuse \
    jq

# ── 1. CURSOR IDE ──────────────────────────────────────────
section "Installing Cursor IDE"

CURSOR_INSTALL_DIR="$HOME/.local/share/cursor"
CURSOR_BIN="$HOME/.local/bin"
mkdir -p "$CURSOR_INSTALL_DIR" "$CURSOR_BIN"

info "Fetching latest Cursor download URL..."

# Cursor publishes a JSON API with the latest AppImage URL
CURSOR_API="https://www.cursor.com/api/download?platform=linux&releaseTrack=stable"
CURSOR_URL=""
for attempt in 1 2 3; do
    CURSOR_URL=$(curl -fsSL --max-time 10 --connect-timeout 5 "$CURSOR_API" 2>/dev/null | jq -r '.downloadUrl // empty' 2>/dev/null || true)
    if [[ -n "$CURSOR_URL" ]]; then
        info "Cursor API fetch successful (attempt $attempt)"
        break
    fi
    if [[ $attempt -lt 3 ]]; then
        warn "API fetch attempt $attempt failed, retrying..."
        sleep 2
    fi
done

# Fallback to known direct URLs if the API doesn't return one
if [[ -z "$CURSOR_URL" ]]; then
    warn "Could not fetch Cursor API after 3 attempts; trying alternative download sources..."
    
    # Try GitHub releases first (most reliable)
    if [[ "$ARCH" == "aarch64" ]]; then
        CURSOR_URL="https://github.com/cursor/cursor/releases/download/latest/Cursor-latest-arm64.AppImage"
    else
        CURSOR_URL="https://github.com/cursor/cursor/releases/download/latest/Cursor-latest-x64.AppImage"
    fi
fi

info "Downloading Cursor from: $CURSOR_URL"
if wget -q --show-progress --timeout=30 --tries=3 -O "$CURSOR_INSTALL_DIR/Cursor.AppImage" "$CURSOR_URL" 2>&1; then
    chmod +x "$CURSOR_INSTALL_DIR/Cursor.AppImage"
    
    # Create launcher wrapper
    cat > "$CURSOR_BIN/cursor" <<'EOF'
#!/usr/bin/env bash
APPIMAGE="$HOME/.local/share/cursor/Cursor.AppImage"

# Try sandbox first; fall back to --no-sandbox (common on Ubuntu with AppArmor)
if "$APPIMAGE" "$@" 2>/dev/null; then
    :
else
    "$APPIMAGE" --no-sandbox "$@"
fi
EOF
    chmod +x "$CURSOR_BIN/cursor"
    
    # Desktop entry
    mkdir -p "$HOME/.local/share/applications"
    cat > "$HOME/.local/share/applications/cursor.desktop" <<EOF
[Desktop Entry]
Name=Cursor
Comment=AI-powered code editor
Exec=$HOME/.local/bin/cursor --no-sandbox %F
Icon=$HOME/.local/share/cursor/cursor-icon.png
Terminal=false
Type=Application
Categories=Development;IDE;TextEditor;
MimeType=text/plain;inode/directory;
StartupNotify=true
EOF
    
    # Try to extract the icon from the AppImage
    info "Extracting Cursor icon..."
    cd /tmp
    "$CURSOR_INSTALL_DIR/Cursor.AppImage" --appimage-extract usr/share/icons &>/dev/null || true
    ICON_SRC=$(find /tmp/squashfs-root -name "*.png" 2>/dev/null | head -1 || true)
    if [[ -n "$ICON_SRC" ]]; then
        cp "$ICON_SRC" "$CURSOR_INSTALL_DIR/cursor-icon.png"
        rm -rf /tmp/squashfs-root
    else
        # Download a fallback icon
        curl -fsSL "https://www.cursor.com/favicon-32x32.png" \
            -o "$CURSOR_INSTALL_DIR/cursor-icon.png" 2>/dev/null || true
    fi
    cd - >/dev/null
    
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
    info "Cursor IDE installed ✓"
else
    warn "Failed to download Cursor IDE - it will not be installed"
    warn "You can install Cursor manually from: https://www.cursor.com"
fi

# ── 2. CLAUDE CODE ─────────────────────────────────────────
section "Installing Claude Code"

# Recommended: Anthropic native installer (no Node.js needed, auto-updates)
CLAUDE_INSTALLER_URL="https://claude.ai/install.sh"

info "Running Anthropic native installer..."
if curl -fsSL "$CLAUDE_INSTALLER_URL" | bash; then
    info "Claude Code installed via native installer ✓"
    CLAUDE_INSTALLED=true
else
    warn "Native installer failed — falling back to npm method."
    CLAUDE_INSTALLED=false
fi

if [[ "$CLAUDE_INSTALLED" == "false" ]]; then
    # ── npm fallback ──────────────────────────────────────
    section "Fallback: installing Claude Code via npm"

    # Install Node.js 22 LTS via NodeSource if not present / too old
    NODE_OK=false
    if command -v node &>/dev/null; then
        NODE_VER=$(node -e "process.exit(parseInt(process.versions.node))" 2>/dev/null; echo $?)
        # A quick check: exit code 0 means version < 18 (process.exit called with it)
        MAJOR=$(node -e "console.log(parseInt(process.versions.node))")
        [[ "$MAJOR" -ge 18 ]] && NODE_OK=true
    fi

    if [[ "$NODE_OK" == "false" ]]; then
        info "Installing Node.js 22 LTS via NodeSource..."
        curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
        sudo apt install -y nodejs
    else
        info "Node.js $(node --version) already satisfies requirement (>=18)."
    fi

    # Configure npm global prefix to avoid sudo
    NPM_PREFIX="$HOME/.npm-global"
    mkdir -p "$NPM_PREFIX"
    npm config set prefix "$NPM_PREFIX"

    info "Installing @anthropic-ai/claude-code globally..."
    npm install -g @anthropic-ai/claude-code

    CLAUDE_BIN="$NPM_PREFIX/bin"

    # Add npm global bin to PATH if not already there
    if ! grep -q "\.npm-global/bin" "$HOME/.bashrc" 2>/dev/null; then
        echo '' >> "$HOME/.bashrc"
        echo '# npm global bin (added by install_cursor_claudecode.sh)' >> "$HOME/.bashrc"
        echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> "$HOME/.bashrc"
    fi
    if [[ -f "$HOME/.zshrc" ]] && ! grep -q "\.npm-global/bin" "$HOME/.zshrc"; then
        echo '' >> "$HOME/.zshrc"
        echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> "$HOME/.zshrc"
    fi
    export PATH="$CLAUDE_BIN:$PATH"
    info "Claude Code installed via npm ✓"
fi

# ── 3. PATH hygiene ────────────────────────────────────────
section "Ensuring ~/.local/bin is on PATH"

for RC in "$HOME/.bashrc" "$HOME/.zshrc"; do
    [[ -f "$RC" ]] || continue
    if ! grep -q '\.local/bin' "$RC"; then
        echo '' >> "$RC"
        echo '# local bin (added by install_cursor_claudecode.sh)' >> "$RC"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$RC"
    fi
done
export PATH="$HOME/.local/bin:$PATH"

# ── Verify ─────────────────────────────────────────────────
section "Verification"

if command -v cursor &>/dev/null; then
    info "cursor  → $(command -v cursor)"
else
    warn "'cursor' not found in PATH yet. Run: source ~/.bashrc  (or open a new terminal)"
fi

if command -v claude &>/dev/null; then
    CLAUDE_VER=$(claude --version 2>/dev/null || echo "unknown")
    info "claude  → $(command -v claude)  ($CLAUDE_VER)"
else
    warn "'claude' not found in PATH yet. Run: source ~/.bashrc  (or open a new terminal)"
fi

# ── Done ───────────────────────────────────────────────────
section "All done!"
echo ""
echo -e "  ${GREEN}Cursor IDE${NC}  → run:  ${YELLOW}cursor${NC}   (or find it in your app launcher)"
echo -e "  ${GREEN}Claude Code${NC} → run:  ${YELLOW}claude${NC}   then authenticate with your Anthropic account"
echo ""
echo -e "  ${YELLOW}Tip:${NC} Reload your shell first:  source ~/.bashrc"
echo ""
echo -e "  Claude Code requires a ${YELLOW}Claude Pro / Max / Team / Enterprise${NC}"
echo -e "  or an ${YELLOW}Anthropic Console${NC} account (console.anthropic.com)."
echo ""
