#!/bin/bash

# Must be run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root: sudo $0 [install|uninstall]"
    exit 1
fi

# Configuration
APP_NAME="anpr_dp_client"
REAL_HOME="${SUDO_USER:+/home/$SUDO_USER}"
SOURCE_FILE="$REAL_HOME/repos/tauri-app/src-tauri/target/release/bundle/appimage/anpr_dp_client_0.1.0_amd64.AppImage"
ICON_SOURCE="$REAL_HOME/repos/tauri-app/src-tauri/icons/icon.png"
DEST_DIR="/opt/$APP_NAME"
BIN_LINK="/usr/local/bin/$APP_NAME"
DESKTOP_FILE="/usr/share/applications/$APP_NAME.desktop"
ICON_DIR="/usr/share/pixmaps"

usage() {
    echo "Usage: sudo $0 [install|uninstall]"
    echo "  install    Install ANPR DP Client for all users (default)"
    echo "  uninstall  Remove ANPR DP Client for all users"
    exit 1
}

install_app() {
    echo "Installing $APP_NAME globally..."

    # 1. Create install directory
    mkdir -p "$DEST_DIR"

    # 2. Copy AppImage and make executable
    cp "$SOURCE_FILE" "$DEST_DIR/$APP_NAME.AppImage"
    chmod +x "$DEST_DIR/$APP_NAME.AppImage"

    # 3. Copy icon
    cp "$ICON_SOURCE" "$ICON_DIR/$APP_NAME.png"

    # 4. Create symlink in PATH
    ln -sf "$DEST_DIR/$APP_NAME.AppImage" "$BIN_LINK"

    # 5. Create desktop launcher
    cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=ANPR DP Client
Exec=$DEST_DIR/$APP_NAME.AppImage
Icon=$ICON_DIR/$APP_NAME.png
Type=Application
Categories=Utility;
Terminal=false
EOF

    chmod 644 "$DESKTOP_FILE"

    # 6. Refresh application database
    update-desktop-database /usr/share/applications/

    echo "Global installation complete!"
    echo "  App:      $DEST_DIR/$APP_NAME.AppImage"
    echo "  Icon:     $ICON_DIR/$APP_NAME.png"
    echo "  Symlink:  $BIN_LINK"
    echo "  Launcher: $DESKTOP_FILE"
    echo "All users can now find 'ANPR DP Client' in their app menu."
}

uninstall_app() {
    echo "Uninstalling $APP_NAME globally..."

    # Remove AppImage directory
    rm -rf "$DEST_DIR"

    # Remove symlink
    rm -f "$BIN_LINK"

    # Remove icon
    rm -f "$ICON_DIR/$APP_NAME.png"

    # Remove desktop launcher
    rm -f "$DESKTOP_FILE"

    # Refresh application database
    update-desktop-database /usr/share/applications/

    echo "Global uninstall complete. '$APP_NAME' has been removed for all users."
}

case "${1:-install}" in
    install)   install_app ;;
    uninstall) uninstall_app ;;
    *)         usage ;;
esac
