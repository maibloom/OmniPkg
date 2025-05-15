#!/bin/bash
set -euo pipefail

if ! command -v yay >/dev/null 2>&1; then
    echo "yay is not installed. Installing yay..."
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
fi

echo "Installing snapd using yay..."
yay -S --noconfirm snapd

echo "Enabling snapd services..."
sudo systemctl enable --now snapd.socket
sudo systemctl enable --now snapd.apparmor.service

if [ ! -L /snap ]; then
    echo "Creating /snap symlink..."
    sudo ln -s /var/lib/snapd/snap /snap
fi

echo "Installing snapcraft..."
sudo snap install snapcraft --classic

echo "Snapcraft installation has been completed successfully!"
