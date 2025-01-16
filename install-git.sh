#!/bin/bash

cd /tmp
git clone https://github.com/Donwaztok/hyprland-dotfiles.git
mkdir ~/.config
cp hyprland-dotfiles/* ~/.config
cd hyprland-dotfiles
sudo chmod +x install.sh
./install.sh
