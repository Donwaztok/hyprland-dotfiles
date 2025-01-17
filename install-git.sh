#!/bin/bash

cd /tmp
git clone https://github.com/Donwaztok/hyprland-dotfiles.git
mkdir ~/.config
cp -rf hyprland-dotfiles/* ~/.config/
cd hyprland-dotfiles
./install.sh
