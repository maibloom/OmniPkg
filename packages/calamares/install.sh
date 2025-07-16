#!/bin/bash

if ! command -v yay &> /dev/null; then
    echo "Yay not found. Installing Yay via omnipkg..."
    sudo omnipkg put install yay || { echo "❌ Failed to install Yay with omnipkg"; exit 1; }
else
    echo "✅ Yay is already installed."
fi

echo "Installing Calamares using omnipkg with unsudo..."
sudo omnipkg put install unsudo <<EOF
yay -S --noconfirm calamares
EOF
