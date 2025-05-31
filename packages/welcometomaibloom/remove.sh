#!/bin/bash
set -euo pipefail

echo "Uninstalling welcometomaibloom..."

# Remove the app directory from /usr/local/bin.
if [ -d "/usr/local/bin/welcometomaibloom" ]; then
    sudo rm -rf /usr/local/bin/welcometomaibloom
    echo "Removed /usr/local/bin/welcometomaibloom"
else
    echo "/usr/local/bin/welcometomaibloom not found."
fi

# Remove the desktop file from /usr/share/applications.
if [ -f "/usr/share/applications/welcometomaibloom.desktop" ]; then
    sudo rm -f /usr/share/applications/welcometomaibloom.desktop
    echo "Removed /usr/share/applications/welcometomaibloom.desktop"
else
    echo "/usr/share/applications/welcometomaibloom.desktop not found."
fi

# Remove the desktop file from the user's Desktop directory.
if [ -f "$HOME/Desktop/welcometomaibloom.desktop" ]; then
    rm -f "$HOME/Desktop/welcometomaibloom.desktop"
    echo "Removed $HOME/Desktop/welcometomaibloom.desktop"
else
    echo "$HOME/Desktop/welcometomaibloom.desktop not found."
fi

# Update the desktop database.
sudo update-desktop-database /usr/share/applications/

echo "Uninstallation completed!"
