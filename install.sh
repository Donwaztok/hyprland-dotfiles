#!/bin/bash

if [ -f /etc/pacman.conf ] && [ ! -f /etc/pacman.conf.t2.bkp ]; then
    echo -e "\033[0;32m[PACMAN]\033[0m adding extra spice to pacman..."

    sudo cp /etc/pacman.conf /etc/pacman.conf.t2.bkp
    sudo sed -i "/^#Color/c\Color\nILoveCandy
    /^#VerbosePkgLists/c\VerbosePkgLists
    /^#ParallelDownloads/c\ParallelDownloads = 5" /etc/pacman.conf
    sudo sed -i '/^#\[multilib\]/,+1 s/^#//' /etc/pacman.conf

    sudo pacman -Sy
    sudo pacman -S reflector
    sudo reflector \
        --country Brazil,United_States \
        --protocol https \
        --sort rate \
        --save /etc/pacman.d/mirrorlist
    sudo pacman -Rns reflector

    sudo pacman -Syyu
    sudo pacman -Fy

else
    echo -e "\033[0;33m[SKIP]\033[0m pacman is already configured..."
fi

# Verifica se yay está instalado
if ! command -v yay &> /dev/null; then
    echo "O 'yay' não está instalado. Instalando agora..."

    # Instala as dependências necessárias e o yay
    sudo pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
    cd ..
    rm -rf yay  # Remove o repositório clonado após a instalação
else
    echo "'yay' já está instalado!"
fi

# Instala os pacotes do app.lst
yay --removemake --cleanafter -S $(awk '!/^#/ { print $1 }' app.lst)

# Install Oh My Zsh
curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
sudo usermod --shell $(which zsh) $USER
sudo chsh -s $(which zsh) $USER

cp .zshrc ~/.zshrc
source "$HOME/.oh-my-zsh/oh-my-zsh.sh"
export ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

# install zsh plugins
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# mouse theme on X11
echo "Xcursor.theme: Bibata-Modern-Classic" >> ~/.Xresources
echo "Xcursor.size: 20" >> ~/.Xresources

# install sddm theme
if [ ! -d /etc/sddm.conf.d ]; then
    sudo mkdir -p /etc/sddm.conf.d
fi
sudo tar -xzf hypr/source/Sddm_Candy.tar.gz -C /usr/share/sddm/themes/
sudo touch /etc/sddm.conf.d/kde_settings.conf
sudo cp /etc/sddm.conf.d/kde_settings.conf /etc/sddm.conf.d/kde_settings.t2.bkp
sudo cp /usr/share/sddm/themes/Candy/kde_settings.conf /etc/sddm.conf.d/

# enable services
sudo systemctl enable sddm
sudo systemctl enable NetworkManager

echo "Instalação Concluída"
