#!/bin/bash
# Installation script for Ubuntu Linux machines
# automatically called by the workspaces CLI

# Assumptions:
# - tmux,wget,git already installed
# - ZSH is default shell (set in config.yaml)

# TODO
# - git aliases
# - neovim

set -xeuo pipefail

SCRIPT_DIR=$HOME/dotfiles

echo "=== Weasel dotfiles installer ==="

# -----------------------------------------------
# System config
# -----------------------------------------------
echo "--- Installing system packages ---"
sudo apt-get update
sudo apt-get install -y \
    stow

sudo locale-gen en_IE.UTF-8

# -----------------------------------------------
# mise
# -----------------------------------------------
if ! command -v mise &>/dev/null
then
    curl https://mise.run | sh
fi
{
    pushd "$HOME/.config"
    mise use --path "$HOME/.config/mise.toml" \
        fzf@0.70.0 \
        aqua:sharkdp/bat@0.26.1 \
        btop@1.4.6
    mise lock
    popd
}


# -----------------------------------------------
# Rust toolchain
# -----------------------------------------------
if ! command -v cargo &>/dev/null; then
    echo "--- Installing Rust toolchain ---"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi
# shellcheck disable=SC1091
source "$HOME/.cargo/env" # for later steps


# -----------------------------------------------
#  zoxide
# -----------------------------------------------
if ! command -v zoxide &>/dev/null; then
    echo "--- Installing zoxide ---"
    cargo install zoxide --locked
fi

# -----------------------------------------------
#  Ghostty terminfo
# -----------------------------------------------
tic -x "$SCRIPT_DIR/xterm-ghostty-infocmp"

# -----------------------------------------------
#  Stow dotfiles packages
# -----------------------------------------------
echo "--- Stowing dotfiles ---"

# Packages safe to stow on any machine
# --no-folding because we'll be adding a lot more stuff in the .tmux directory
STOW_PACKAGES=(base tmux)

for pkg in "${STOW_PACKAGES[@]}"; do
    echo "  stowing: $pkg"
    stow -t "$HOME" -v -d "$SCRIPT_DIR/stow" --no-folding "$pkg"
done

if ! grep --silent WEASEL_SOURCE_STOW"$HOME/.zshrc"
then
    echo "Setting up ZSH weasel sourcing"
    cat <<EOF >> "$HOME/.zshrc"
# WEASEL_SOURCE_STOW
source <(fzf --zsh)
source "$HOME/.cargo/env"
# Sourcing the stowed dotfiles
source "$HOME/.weasel_rc/1_base.sh"
EOF
fi

# -----------------------------------------------
#  Tmux
# -----------------------------------------------

if ! grep --silent WEASEL_SOURCE_TMUX "$HOME/.tmux.conf"
then
    echo "Setting up tmux weasel sourcing"
    cat <<EOF >> "$HOME/.tmux.conf"
# WEASEL_SOURCE_TMUX
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

