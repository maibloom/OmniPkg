#!/bin/bash

sudo chmod +x *

sudo pacman -Syy

ls

if [ archinstall ]; then
  sudo chmod +x post-build.sh
  arch-chroot /mnt /post_build.sh
fi
