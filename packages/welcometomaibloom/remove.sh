#!/bin/bash
set -euo pipefail
sudo rm -rf /usr/bin/welcometomaibloom
sudo rm -f /usr/share/applications/welcometomaibloom.desktop
rm -f "$HOME/Desktop/welcometomaibloom.desktop"
sudo update-desktop-database /usr/share/applications/
echo "Uninstallation completed!"
