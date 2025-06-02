#!/bin/bash
TEMP_PASS="SecureTempPass123"
if [ -t 0 ]; then echo "Usage: $0 <<EOF ... EOF" ; exit 1; fi
CMD=$(cat)
CURRENT_USER=$(whoami)
echo "Current user: $CURRENT_USER"
sudo useradd -m -s /bin/bash tempuser
echo "tempuser:$TEMP_PASS" | sudo chpasswd
echo "tempuser ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/tempuser >/dev/null
su - tempuser <<EOF
$CMD
EOF
echo "Logged in as $(whoami)"
sudo rm -f /etc/sudoers.d/tempuser
sudo userdel -r tempuser 2>/dev/null
echo "Temporary user 'tempuser' has been removed."
