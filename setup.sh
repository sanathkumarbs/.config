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

  local parentdir
  parentdir=$(dirname "$destination")  

  if [ ! -d "$parentdir" ]; then
    mkdir -p "$parentdir"
  fi

  if [ ! -L "$destination" ]; then
    echo "Symlinking $full_file_path -> $destination"
    ln -sf "$full_file_path" "$destination"
  fi
}

function copy_dotfile() {
  local file=$1
  local destination=$2
  local full_file_path
  full_file_path="$(dotfiles_location)/$file"

  if [ ! -d "$destination" ]; then
    mkdir -p "$destination"
  fi

  echo "Copying $full_file_path -> $destination"
  cp "$full_file_path" "$destination"
}

function git_clone() {
  local repo_url=$1
  local destination=$2
  if [ ! -e "$destination" ]; then
    git clone "$repo_url" "$destination"
  fi
}

echo "setting up .zshenv"
copy_dotfile zsh/.zshenv "$HOME"/

echo "installing oh-my-zsh"
if [ ! -d "$HOME/.config/zsh/oh-my-zsh" ]; then
  wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
  ZSH="$HOME/.config/zsh/oh-my-zsh" sh -c "$(cat install.sh) --unattended"
  rm install.sh
  rm ~/.zshrc
fi

echo "setting up zsh"
copy_dotfile zsh/.zshenv "$HOME"/
symlink_dotfile zsh/.zshrc "$HOME"/.config/zsh/.zshrc
symlink_dotfile zsh/.zprofile "$HOME"/.config/zsh/.zprofile
symlink_dotfile zsh/.p10k.zsh "$HOME"/.config/zsh/.p10k.zsh

echo "using powerlevel10k for zsh"
export ZSH_CUSTOM="$HOME/.config/zsh/oh-my-zsh/custom"
git_clone https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM"/themes/powerlevel10k

echo "adding zsh plugins"
git_clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM"/plugins/zsh-autosuggestions
git_clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM"/plugins/zsh-syntax-highlighting
git_clone https://github.com/marlonrichert/zsh-autocomplete.git "$ZSH_CUSTOM"/plugins/zsh-autocomplete

echo "finished setting up zsh... 🚀"

if [ -f "$HOME"/work/dotfiles/setup.sh ]; then
  echo "setting up work dotfiles... "
  # shellcheck source=/dev/null
  source "$HOME"/work/dotfiles/setup.sh
else
  echo "failed to setup work dotfiles, setup.sh not found in $HOME/work/dotfiles/"
fi