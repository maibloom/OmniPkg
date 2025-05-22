#!/bin/bash

sudo chmod +x *

sudo pacman -Syy

python archinstallscript.py

sudo bash post-build.sh
