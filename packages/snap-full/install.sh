#!/bin/bash
set -euo pipefail

if [ -d "snapd" ]; then
    echo "Removing existing snapd directory..."
    rm -rf snapd
fi

echo "Cloning snapd from the AUR..."
git clone https://aur.archlinux.org/snapd.git

cd snapd

echo "Building and installing snapd (this may take a while)..."
yes | makepkg -si

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
