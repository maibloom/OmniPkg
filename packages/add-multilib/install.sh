grep -qxF "[multilib]" /etc/pacman.conf || sudo tee -a /etc/pacman.conf << 'EOF'
[multilib]
Include = /etc/pacman.d/mirrorlist
EOF

echo "Multilib has been added successfully"
