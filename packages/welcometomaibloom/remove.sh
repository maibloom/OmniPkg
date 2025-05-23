#!/bin/bash
set -euo pipefail

# Define installation paths
APP_DIR="/usr/bin/welcometomaibloom"
SYSTEM_DESKTOP_FILE="/usr/share/applications/welcometomaibloom.desktop"

# Determine the current user for desktop file removal
if [[ -n "${SUDO_USER:-}" ]]; then
    USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    USER_HOME="$HOME"
fi
USER_DESKTOP_FILE="$USER_HOME/Desktop/welcometomaibloom.desktop"

# Remove the application directory if it exists
if [ -d "$APP_DIR" ]; then
    sudo rm -rf "$APP_DIR"
    echo "Removed application directory: $APP_DIR"
else
    echo "Warning: Application directory $APP_DIR not found."
fi

# Remove the system desktop file if it exists
if [ -f "$SYSTEM_DESKTOP_FILE" ]; then
    sudo rm -f "$SYSTEM_DESKTOP_FILE"
    echo "Removed system desktop file: $SYSTEM_DESKTOP_FILE"
else
    echo "Warning: System desktop file $SYSTEM_DESKTOP_FILE not found."
fi

# Remove the user desktop shortcut if it exists
if [ -f "$USER_DESKTOP_FILE" ]; then
    rm -f "$USER_DESKTOP_FILE"
    echo "Removed user desktop shortcut: $USER_DESKTOP_FILE"
else
    echo "Warning: User desktop shortcut $USER_DESKTOP_FILE not found."
fi

# Update the desktop database to reflect the removal
sudo update-desktop-database /usr/share/applications
echo "Uninstallation completed!"
