if [ -f /usr/bin/TuxTalk ]; then
    sudo rm -rf /usr/bin/TuxTalk
fi

sudo pacman -S python-pipx python-pyqt5

# pipx install transformers torch

git clone https://github.com/maibloom/TuxTalk.git

cd TuxTalk/v1.0.0

chmod +x ./TuxTalkInstall.sh

echo ">>> INSTALLATION IS IN PROCESS <<<"

sudo bash ./TuxTalkInstall.sh