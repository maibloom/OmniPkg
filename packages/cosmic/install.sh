sudo pacman -S cosmic --noconfirm

sudo pacman -S cosmic-session --noconfirm

sudo pacman -S gdm --noconfirm
sudo systemctl enable gdm.service
sudo pacman -S cosmic-greeter --noconfirm
sudo systemctl enable cosmic-greeter.service

sudo pacman -S packagekit power-profiles-daemon xdg-user-dirs --noconfirm
sudo systemctl enable power-profiles-daemon.service
xdg-user-dirs-update

sudo pacman -S gnome-keyring --noconfirm
sudo pacman -S cosmic-text-editor cosmic-player --noconfirm
