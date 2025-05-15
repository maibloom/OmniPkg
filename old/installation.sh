if sudo mkdir /usr/local/bin/; then
    echo "Directory /usr/local/bin has created successfully."
else
    echo "Directory /usr/local/bin exists, or the process of creation has failed."
fi
if sudo mv omnipkg /usr/local/bin/omnipkg; then
    echo "source codes have moved to /usr/local/bin/omnipkg"
else
    echo "the process of moving the source code has failed. This can be due to the file being already moved or the file not existing. continuing..."
fi
if sudo chmod +x /usr/local/bin/omnipkg; then
    echo "the source code now has promissions"
else
    echo "The source code doesn't have permissions. please give the permission manually."
fi
echo "The source codes have stablishes successfully on the device. Continuing with the installation of Yay"

sudo pacman -Syu && sudo pacman -Syu && base-devel git && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si

if yay --version; then
    echo "Installation of Yay was successful. Now, you can use Omni Package."
else
    echo "Installation of Yay was NOT successful. please try reinstalling it manually."
fi