# 1. Create the directory where the script will reside
sudo mkdir -p /usr/local/bin/omnipkg/

# 2. Move the omnipkg.py script to the correct directory
sudo mv omnipkg.py /usr/local/bin/omnipkg/
sudo mv omnipkgupdater.py /usr/local/bin/omnipkg/

# 3. Make the script executable
sudo chmod +x /usr/local/bin/omnipkg/omnipkg.py

# 4. Create a symbolic link to make the script accessible as 'omnipkg' command
sudo ln -s /usr/local/bin/omnipkg/omnipkg.py /usr/local/bin/omnipkg/omnipkg

# 5. Ensure Python is installed (required to run the script)
sudo pacman -S python python3