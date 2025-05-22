#!/bin/bash

sudo chmod +x *

if [ archinstall ] then;
  sudo chmod +x post-build.sh
  arch-chroot /mnt /post_build.sh
