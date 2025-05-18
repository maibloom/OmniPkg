if [ -f /usr/bin/TuxTalk ]; then
    sudo rm -rf /usr/bin/TuxTalk
fi

if [ omnipkg defdis == "debian" ]; then
    sudo apt install python-pipx python-pyqt5 --noconfirm
elif [ omnipkg defdis == "arch" ]; then
    sudo pacman -S python-pipx python-pyqt5 --noconfirm
fi

git clone https://github.com/maibloom/TuxTalk.git

cd TuxTalk/v1.0.0

chmod +x ./TuxTalkInstall.sh

echo ">>> INSTALLATION IS IN PROCESS <<<"

sudo bash ./TuxTalkInstall.sh
