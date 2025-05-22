#!/bin/bash

sudo chmod +x *

sudo pacman -Syy

archinstall

sudo chmod +x post-build.sh

sudo cp post-build.sh /mnt/post-build.sh

arch-chroot /mnt

sudo pacman -Syyu git unzip curl --noconfirm

sudo bash post-build.sh
