#!/bin/bash
set -euxo pipefail

sudo -v
# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

function dotfiles_location() {
  echo "$HOME/personal/.config"
}

function symlink_dotfile() {
  local file=$1
  local destination=$2
  local full_file_path
  full_file_path="$(dotfiles_location)/$file"

  mkdir -p "$(dirname "$destination")"
  echo "Symlinking $full_file_path -> $destination"
  ln -sf "$full_file_path" "$destination"
}

function copy_dotfile() {
  local file=$1
  local destination=$2
  local full_file_path
  full_file_path="$(dotfiles_location)/$file"
  
  # mkdir -p $(dirname $destination)

  #if [ ! -e "$destination" ]; then
    echo "Copying $full_file_path -> $destination"
    cp "$full_file_path" "$destination"
  #fi
}

echo "setting up .zshenv"
copy_dotfile zsh/.zshenv "$HOME"/

echo "installing oh-my-zsh"
wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
ZSH="$HOME/.config/zsh/oh-my-zsh" sh -c "$(cat install.sh) --unattended"
rm install.sh

echo "setting up zsh"
symlink_dotfile zsh/.zshrc "$HOME"/.config/zsh/.zshrc
symlink_dotfile zsh/.zprofile "$HOME"/.config/zsh/.zprofile

echo "using powerlevel10k for zsh"
export ZSH_CUSTOM="$HOME/.config/zsh/oh-my-zsh/custom"
git clone https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM"/themes/powerlevel10k

echo "adding zsh plugins"
git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM"/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM"/plugins/zsh-syntax-highlighting
git clone https://github.com/marlonrichert/zsh-autocomplete.git "$ZSH_CUSTOM"/plugins/zsh-autocomplete

echo "finished setting up zsh... 🚀"
