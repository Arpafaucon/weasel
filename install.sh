#!/bin/bash
# Installation script for Ubuntu Linux machines
# automatically called by the workspaces CLI

# Assumptions:
# - tmux,wget,git already installed
# - ZSH is default shell (set in config.yaml)

# TODO
# - git aliases
# - neovim

set -euo pipefail

SCRIPT_DIR=$HOME/dotfiles

echo "=== Weasel dotfiles installer ==="

# -----------------------------------------------
# System config
# -----------------------------------------------
echo "--- Installing system packages ---"
sudo apt-get update
sudo apt-get install -y \
    stow \
    fzf

sudo locale-gen en_IE.UTF-8

# -----------------------------------------------
# Rust toolchain
# -----------------------------------------------
if ! command -v cargo &>/dev/null; then
    echo "--- Installing Rust toolchain ---"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi
source "$HOME/.cargo/env" # for later steps

# -----------------------------------------------
#  zoxide (smarter cd)
# -----------------------------------------------
if ! command -v zoxide &>/dev/null; then
    echo "--- Installing zoxide ---"
    cargo install zoxide --locked
fi

# -----------------------------------------------
#  Ghostty terminfo
# -----------------------------------------------
tic -x xterm-ghostty-infocmp

# -----------------------------------------------
#  Stow dotfiles packages
# -----------------------------------------------
echo "--- Stowing dotfiles ---"

# Packages safe to stow on any machine
STOW_PACKAGES=(base tmux)

for pkg in "${STOW_PACKAGES[@]}"; do
    echo "  stowing: $pkg"
    stow -t "$HOME" -v -d "$SCRIPT_DIR/stow" "$pkg"
done

if ! grep --silent WEASEL_SOURCE "$HOME/.zshrc"
then
    echo "Setting up ZSH weasel sourcing"
    cat <<EOF >> "$HOME/.zshrc"
# WEASEL_SOURCE
source "$HOME/.cargo/env"
# Sourcing the stowed dotfiles
source "$HOME/.weasel_rc/1_base.sh"
EOF
fi

# -----------------------------------------------
#  Tmux
# -----------------------------------------------

if ! grep --silent WEASEL_SOURCE "$HOME/.tmux.conf"
then
    echo "Setting up tmux weasel sourcing"
    cat <<EOF >> "$HOME/.tmux.conf"
# WEASEL_SOURCE
# Sourcing the stowed dotfiles
source-file ~/.tmux/tmux_global.conf
source-file ~/.tmux/tmux_remote.conf
EOF
fi

if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    echo "--- Installing Tmux Plugin Manager ---"
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

echo "--- Installing tmux plugins via tpm ---"
if [[ -x "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]]; then
    "$HOME/.tmux/plugins/tpm/bin/install_plugins"
fi


echo ""
echo "=== Installation complete ==="

