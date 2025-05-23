#!/bin/bash
set -euo pipefail

sudo rm /usr/share/applications/welcometomaibloom.desktop
sudo rm -rf /usr/local/bin/welcometomaibloom/

# Update the desktop database to reflect the removal
sudo update-desktop-database /usr/share/applications
echo "Uninstallation completed!"
