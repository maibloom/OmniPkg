#!/usr/bin/env bash
set -euo pipefail

APP_NAME=welcometomaibloom
INSTALL_DIR=/opt/$APP_NAME
BIN_LINK=/usr/bin/$APP_NAME
ICON_SIZE=256x256
ICON_DIR=/usr/share/icons/hicolor/$ICON_SIZE/apps
DESKTOP_DIR=/usr/share/applications

# 1. Remove the symlink in /usr/bin and the whole install dir
sudo rm -f "$BIN_LINK"
sudo rm -rf "$INSTALL_DIR"

# 2. Remove the icon from the hicolor cache
sudo rm -f "$ICON_DIR/$APP_NAME.png"

# 3. Remove the system-wide .desktop launcher
sudo rm -f "$DESKTOP_DIR/$APP_NAME.desktop"

# 4. Remove the user’s copy on their Desktop (if it exists)
if [[ -n "${SUDO_USER:-}" ]]; then
    USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    USER_HOME="$HOME"
fi

if [[ -d "$USER_HOME/Desktop" ]]; then
    rm -f "$USER_HOME/Desktop/$APP_NAME.desktop"
fi

# 5. Refresh the desktop database (if available)
if command -v update-desktop-database &> /dev/null; then
    sudo update-desktop-database "$DESKTOP_DIR"
fi

echo "Uninstallation of $APP_NAME complete!"