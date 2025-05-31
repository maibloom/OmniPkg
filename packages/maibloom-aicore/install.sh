#!/bin/bash
set -euo pipefail

echo "=============================================="
echo "Setting up Reflector to run automatically..."
echo "=============================================="

# Step 1: Install Reflector if it isn't already installed.
echo "Installing reflector (if needed)..."
sudo pacman -S --needed reflector --noconfirm

# Step 2: Configure Reflector
# This sample config retrieves the latest 5 HTTPS-only mirrors sorted by download rate
# and saves the list to /etc/pacman.d/mirrorlist.
CONFIG_FILE="/etc/xdg/reflector/reflector.conf"
echo "Writing sample configuration to ${CONFIG_FILE}..."
sudo tee "$CONFIG_FILE" >/dev/null <<'EOF'
--latest 5 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
EOF

echo "Reflector configuration saved to ${CONFIG_FILE}"

# Step 3: Enable and start the Reflector systemd timer.
# The reflector.timer is provided by the package and (typically) runs weekly by default.
# If you wish to change the interval, you can edit the timer unit later.
echo "Enabling and starting reflector.timer..."
sudo systemctl enable --now reflector.timer

# Reload systemd so that any changes are recognized.
sudo systemctl daemon-reload


omnipkg put install pypippark

sudo pacman -S --needed python-pytorch --noconfirm

sudo pypippark install trl transformers torch

git clone https://www.github.com/maibloom/maibloom-aicore

cd maibloom-aicore/

chmod +x *

sudo mkdir -p /usr/local/bin/maibloom-aicore-folder

sudo cp maibloom-aicore.sh /usr/local/bin/maibloom-aicore

sudo cp * /usr/local/bin/maibloom-aicore-folder

sudo maibloom-aicore "What do you think about GNU/Linux operating system?" --verbose
