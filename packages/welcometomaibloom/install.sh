sudo mkdir -p /usr/bin/welcometomaibloom
sudo mkdir -p /usr/share/applications/

chmod +x welcometomaibloom.desktop
chmod +x welcometomaibloom.py

sudo cp welcometomaibloom.py /usr/bin/welcometomaibloom
sudo cp icon.png /usr/bin/welcometomaibloom
sudo cp welcometomaibloom.desktop /usr/share/applications/
sudo cp welcometomaibloom.desktop ~/Desktop
sudo update-desktop-database /usr/share/applications/

echo "Installation completed!"
