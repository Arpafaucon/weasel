#!/bin/bash
# Installation script for Ubuntu Linux machines
# to be used with the workspaces CLI
# Sets up all tools referenced by this dotfiles repo

# Assumptions provided by workspaces
# tmux,wget,git already installed
# ZSH is default shell (set in config.yaml)


set -euo pipefail

SCRIPT_DIR=$HOME/dotfiles

echo "=== Weasel dotfiles installer (Ubuntu) ==="

# -----------------------------------------------
# 1. System packages (apt)
# -----------------------------------------------
echo "--- Installing system packages via apt ---"
sudo apt-get update
sudo apt-get install -y \
    curl \
    wget \
    stow \
    build-essential

sudo locale-gen en_IE.UTF-8

# skipped for now
# # -----------------------------------------------
# # 2. Neovim (latest stable PPA)
# # -----------------------------------------------
# if ! command -v nvim &>/dev/null; then
#     echo "--- Installing Neovim ---"
#     sudo add-apt-repository -y ppa:neovim-ppa/stable
#     sudo apt-get update
#     sudo apt-get install -y neovim
# else
#     echo "--- Neovim already installed ---"
# fi

# -----------------------------------------------
# 3. Rust toolchain
# -----------------------------------------------
if ! command -v cargo &>/dev/null; then
    echo "--- Installing Rust toolchain ---"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
else
    echo "--- Rust toolchain already installed ---"
fi
source "$HOME/.cargo/env" # for later steps

# -----------------------------------------------
# 4. fzf (fuzzy finder)
# -----------------------------------------------
if ! command -v fzf &>/dev/null; then
    echo "--- Installing fzf ---"
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all --no-bash --no-fish
else
    echo "--- fzf already installed ---"
fi

# -----------------------------------------------
# 5. zoxide (smarter cd)
# -----------------------------------------------
if ! command -v zoxide &>/dev/null; then
    echo "--- Installing zoxide ---"
    cargo install zoxide --locked
else
    echo "--- zoxide already installed ---"
fi

# -----------------------------------------------
# 6. mise (version manager, asdf alternative)
# -----------------------------------------------
if ! command -v mise &>/dev/null; then
    echo "--- Installing mise ---"
    curl https://mise.run | sh
else
    echo "--- mise already installed ---"
fi

# -----------------------------------------------
# 7. Powerlevel10k (zsh theme)
# -----------------------------------------------
if [[ ! -d "$HOME/powerlevel10k" ]]; then
    echo "--- Installing Powerlevel10k ---"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
else
    echo "--- Powerlevel10k already installed ---"
fi

# -----------------------------------------------
# 9. Stow dotfiles packages
# -----------------------------------------------
echo "--- Stowing dotfiles ---"

# Packages safe to stow on any machine
STOW_PACKAGES=(base tmux)

for pkg in "${STOW_PACKAGES[@]}"; do
    echo "  stowing: $pkg"
    stow -t "$HOME" -v -d "$SCRIPT_DIR/stow" "$pkg"
done

echo ""
echo "--- Optional stow packages (not auto-applied) ---"
echo "  datadog  - Datadog workspace config (stow -t \$HOME -v -d $SCRIPT_DIR/stow datadog)"
echo "  local_rc - Machine-specific shell overrides (stow -t \$HOME -v -d $SCRIPT_DIR/stow local_rc)"

if ! grep WEASEL_SOURCE "$HOME/.zshrc"
then
    echo "Setting up ZSH weasel sourcing"
    cat <<EOF >> "$HOME/.zshrc"
# WEASEL_SOURCE
source "$HOME/.cargo/env"
# Sourcing the stowed dotfiles
source "$HOME/.weasel_rc/1_base.sh"
# p10k
source "$HOME/.p10k.zsh"
source "$HOME/powerlevel10k/powerlevel10k.zsh-theme"
EOF
fi

# -----------------------------------------------
# 8. Tmux
# -----------------------------------------------

if ! grep WEASEL_SOURCE "$HOME/.tmux.conf"
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
else
    echo "--- tpm already installed ---"
fi

echo "--- Installing tmux plugins via tpm ---"
if [[ -x "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]]; then
    "$HOME/.tmux/plugins/tpm/bin/install_plugins"
fi


echo ""
echo "=== Installation complete ==="

