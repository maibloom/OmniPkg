#!/bin/bash

if [ touch /usr/local/bin/bloominstall/ ] then;
  sudo rm -rf /usr/local/bin/bloominstall/

sudo mkdir /usr/local/bin/bloominstall/

sudo cp * /usr/local/bin/bloominstall/

sudo chmod +x /usr/local/bin/bloominstall/*
