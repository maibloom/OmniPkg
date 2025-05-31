#!/bin/bash
set -euo pipefail

# Install yay if not available (assumes network and build environment are present)
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

# Conditionally enable snapd services if systemd is active
if [ -d /run/systemd/system ]; then
    echo "Enabling snapd services..."
    systemctl enable --now snapd.socket
    systemctl enable --now snapd.apparmor.service
else
    echo "Not in an active systemd environment (likely arch-chroot)."
    echo "Please enable snapd services after booting your system."
fi

# Create the /snap symlink for classic snap support
if [ ! -L /snap ]; then
    echo "Creating /snap symlink..."
    ln -s /var/lib/snapd/snap /snap
fi

# Attempt to install snapcraft
if command -v snap >/dev/null 2>&1; then
    echo "Installing snapcraft..."
    snap install snapcraft --classic
else
    echo "The 'snap' command is not available. It will be available after the snapd daemon is running."
    echo "After booting, run: snap install snapcraft --classic"
fi

sudo systemctl enable --now snapd.socket
sudo systemctl enable --now snapd.apparmor.service
sudo snap install snapcraft --classic


echo "Installation steps for Snapcraft have been completed (pending system boot for service activation)."
