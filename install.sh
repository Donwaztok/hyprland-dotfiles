#!/bin/bash

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

yay --noconfirm -S $(awk '!/^#/ { print $1 }' app.lst)

# set variables
Zsh_rc="${ZDOTDIR:-$HOME}/.zshrc"
Zsh_Path="/usr/share/oh-my-zsh"
Zsh_Plugins="$Zsh_Path/custom/plugins"
Fix_Completion=""

# generate plugins from list
while read r_plugin; do
    z_plugin=$(echo "${r_plugin}" | awk -F '/' '{print $NF}')
    if [ "${r_plugin:0:4}" == "http" ] && [ ! -d "${Zsh_Plugins}/${z_plugin}" ]; then
        sudo git clone "${r_plugin}" "${Zsh_Plugins}/${z_plugin}"
    fi
    if [ "${z_plugin}" == "zsh-completions" ] && [ "$(grep 'fpath+=.*plugins/zsh-completions/src' "${Zsh_rc}" | wc -l)" -eq 0 ]; then
        Fix_Completion='\nfpath+=${ZSH_CUSTOM:-${ZSH:-/usr/share/oh-my-zsh}/custom}/plugins/zsh-completions/src'
    else
        [ -z "${z_plugin}" ] || w_plugin+=" ${z_plugin}"
    fi
done < <(cut -d '#' -f 1 "${scrDir}/restore_zsh.lst" | sed 's/ //g')

# update plugin array in zshrc
echo -e "\033[0;32m[SHELL]\033[0m installing plugins (${w_plugin} )"
sed -i "/^plugins=/c\plugins=(${w_plugin} )${Fix_Completion}" "${Zsh_rc}"

# set shell
if [[ "$(grep "/${USER}:" /etc/passwd | awk -F '/' '{print $NF}')" != "${myShell}" ]]; then
    echo -e "\033[0;32m[SHELL]\033[0m changing shell to ${myShell}..."
    chsh -s "$(which "${myShell}")"
else
    echo -e "\033[0;33m[SKIP]\033[0m ${myShell} is already set as shell..."
fi

echo "Instalação Concluída"
