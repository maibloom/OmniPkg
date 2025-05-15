git clone https://aur.archlinux.org/google-chrome.git

cd google-chrome/

makepkg -s

ls

sudo pacman -U --noconfirm google*