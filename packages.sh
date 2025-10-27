#!/bin/bash

# Update package list
sudo apt-get update

# Install packages using apt-get
sudo apt-get install -y \
    xdg-utils \
    jq \
    shellcheck \
    tmux \
    tree \
    wget \
    zsh \
    gh

# Install fzf from git
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all

# Install z
mkdir -p ~/.local/bin
curl -o ~/.local/bin/z.sh https://raw.githubusercontent.com/rupa/z/master/z.sh
chmod +x ~/.local/bin/z.sh

# Add z to shell configuration if not already present
Z_CONFIG='[ -f ~/.local/bin/z.sh ] && source ~/.local/bin/z.sh'
grep -q "$Z_CONFIG" ~/.zshrc || echo "$Z_CONFIG" >> ~/.zshrc

# Install zsh-syntax-highlighting
ZSH_SYNTAX_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
if [ ! -d "$ZSH_SYNTAX_DIR" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_SYNTAX_DIR"
fi

# Add zsh-syntax-highlighting to plugins if not already present
if ! grep -q "plugins=.*zsh-syntax-highlighting" ~/.zshrc; then
    # If plugins line exists, append to it
    if grep -q "^plugins=(" ~/.zshrc; then
        sed -i 's/^plugins=(/&zsh-syntax-highlighting /' ~/.zshrc
    else
        # If no plugins line exists, create it
        echo "plugins=(zsh-syntax-highlighting)" >> ~/.zshrc
    fi
    echo "Added zsh-syntax-highlighting to plugins in ~/.zshrc"
fi

# Verify installations
echo "Installed versions:"
echo "fzf: $(~/.fzf/bin/fzf --version)"
echo "jq: $(jq --version)"
echo "shellcheck: $(shellcheck --version)"
echo "tmux: $(tmux -V)"
echo "tree: $(tree --version | head -n 1)"
echo "wget: $(wget --version | head -n 1)"
echo "z: installed at ~/.local/bin/z.sh"
echo "zsh: $(zsh --version)"
echo "zsh-syntax-highlighting: installed at $ZSH_SYNTAX_DIR"
echo "gh: $(gh --version)"