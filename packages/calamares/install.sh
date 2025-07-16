#!/bin/bash

if ! command -v yay &> /dev/null; then
    echo "Yay not found. Installing Yay via omnipkg..."
    sudo omnipkg put install yay || { echo "❌ Failed to install Yay with omnipkg"; exit 1; }
else
    echo "✅ Yay is already installed."
fi

echo "Installing some dependencies..."
sudo pacman -S --needed --noconfirm hwinfo kpmcore


echo "Installing ckbcomp, mkinitcpio-openswap, and Calamares using omnipkg with unsudo..."
sudo omnipkg put install unsudo <<EOF
yay --noconfirm -S ckbcomp mkinitcpio-openswap || {
  echo "❌ Failed to build/install ckbcomp or mkinitcpio-openswap"; exit 1;
}
yay --noconfirm -S calamares || {
  echo "❌ Calamares install failed again"; exit 1;
}
EOF
