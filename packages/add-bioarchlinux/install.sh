grep -qxF "[bioarchlinux]" /etc/pacman.conf || sudo tee -a /etc/pacman.conf << 'EOF'
[bioarchlinux]
Server = https://repo.bioarchlinux.org/$arch
EOF

pacman-key --recv-keys B1F96021DB62254D
pacman-key --finger B1F96021DB62254D
pacman-key --lsign-key B1F96021DB62254D

sudo pacman -Syu --noconfirm

echo "BioArchLinux has been added successfully"
