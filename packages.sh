#!/bin/bash
set -euo pipefail

# Package installation, per OS:
#   macOS  -> Homebrew, declaratively from homebrew/Brewfile
#   Linux  -> apt + a couple of source installs (devbox)
# Shell config (z sourcing, plugins) is owned by zsh/.zshrc, NOT this script —
# it deliberately does not touch ~/.zshrc.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "macOS detected — installing via Homebrew (homebrew/Brewfile)"
  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew not found. Install it first: https://brew.sh" >&2
    exit 1
  fi
  brew bundle --file="$DIR/homebrew/Brewfile"
  echo "brew bundle complete 🚀"
else
  echo "Linux detected — installing via apt + source"
  sudo apt-get update
  sudo apt-get install -y \
    xdg-utils \
    jq \
    shellcheck \
    tmux \
    tree \
    wget \
    zsh \
    gh

  # fzf — binary only; keybindings/completion are left to shell config
  [ -d "$HOME/.fzf" ] || git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
  "$HOME/.fzf/install" --bin

  # z — zsh/.zshrc sources this from ~/.local/bin/z.sh on Linux
  mkdir -p "$HOME/.local/bin"
  curl -fsSL -o "$HOME/.local/bin/z.sh" https://raw.githubusercontent.com/rupa/z/master/z.sh
  chmod +x "$HOME/.local/bin/z.sh"

  echo "apt + source installs complete 🚀"
fi
