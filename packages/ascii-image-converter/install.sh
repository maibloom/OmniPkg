git clone https://aur.archlinux.org/ascii-image-converter-git.git /tmp/ascii-image-converter-git/

cd /tmp/ascii-image-converter-git/

makepkg -si --noconfirm


if command -v yay &> /dev/null; then
  yay -S ascii-image-converter-git --noconfirm
else
  echo "yay is not installed. Using OmniPkg to install yay..."
  omnipkg put install yay
  yay -S ascii-image-converter-git --noconfirm
fi
