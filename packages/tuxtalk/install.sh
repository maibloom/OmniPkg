if [ -f /usr/bin/TuxTalk ]; then
    sudo rm -rf /usr/bin/TuxTalk
fi

# cayn@cayn:~$ omnipkg defdis
# "debian" 

distro="$(omnipkg defdis | tr -d '"')"

if [ "$distro" = "debian" ]; then
    sudo apt install python3-pip
    python3 -m pip install --user pipx pyqt5
elif [ "$distro" = "arch" ]; then
    sudo pacman -S python-pipx python-pyqt5 --noconfirm
fi



git clone https://github.com/maibloom/TuxTalk.git

cd TuxTalk/v1.0.0

chmod +x ./TuxTalkInstall.sh

echo ">>> INSTALLATION IS IN PROCESS <<<"

sudo bash ./TuxTalkInstall.sh
