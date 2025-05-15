git clone https://aur.archlinux.org/snapd.git

cd snapd

makepkg -si

sudo systemctl enable --now snapd.socket

sudo systemctl enable --now snapd.apparmor.service

sudo ln -s /var/lib/snapd/snap /snap

sudo snap install snapcraft --classic