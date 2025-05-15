git clone https://aur.archlinux.org/google-chrome.git

cd google-chrome/

makepkg -s

sudo pacman -U --noconfirm google-chrome*.xzss