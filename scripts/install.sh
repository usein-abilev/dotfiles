#!/bin/bash

# Exit on error
set -e

echo "--- Starting Setup ---"
echo "--- Installing dependencies ---"
sudo apt upgrade && sudo apt update && sudo apt install -y zsh stow curl git

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "--- Installing Oh My Zsh ---"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "--- Oh My Zsh already installed ---"
fi

# Set Zsh as default shell
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "--- Changing default shell to Zsh ---"
    chsh -s "$(which zsh)"
fi

# Install Neovim Nightly (v0.11+)
echo "--- Installing Neovim Nightly ---"
# Remove old installation if exists
if [ -d "/opt/nvim-linux-x86_64" ]; then
    sudo rm -rf /opt/nvim-linux-x86_64
fi

curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-x86_64.tar.gz
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
rm nvim-linux-x86_64.tar.gz

# Configure .zshrc
echo "--- Updating .zshrc ---"
ZSHRC="$HOME/.zshrc"

# Installing Volta for managing Nodejs versions
curl https://get.volta.sh | bash

cat <<EOT >> "$ZSHRC"

# --- Custom Configuration ---
export PATH="\$PATH:/opt/nvim-linux-x86_64/bin"
alias vi='nvim'
alias vim='nvim'
export VOLTA_HOME="\$HOME/.volta"
export PATH="\$VOLTA_HOME/bin:\$PATH"

export GOROOT=/usr/local/go
export GOPATH=\$HOME/go
export PATH=\$PATH:\$GOROOT/bin:\$GOPATH/bin

# Press Ctrl-f to fuzzy find a folder and open it as a Tmux session
bindkey -s '^f' 'tmux-sessionizer\n'

# Make nvim a primary editor for sudoedit
export EDITOR='/opt/nvim-linux-x86_64/bin/nvim'
export VISUAL='/opt/nvim-linux-x86_64/bin/nvim'
export SUDO_EDITOR='/opt/nvim-linux-x86_64/bin/nvim'
EOT

# Run Stow
echo "--- Stowing dotfiles ---"
# Ensures target directory exists
mkdir -p "$HOME/.config"

# Check if dotfiles source exists
if [ -d "$HOME/dotfiles/config" ]; then
    # Stow everything inside ~/dotfiles/config into ~/.config
    cd "$HOME/dotfiles/config"
    stow -v -t "$HOME/.config" .
else
    echo "Warning: $HOME/dotfiles/config not found. Skipping stow."
fi

echo "--- Setup Complete! Please restart your terminal. ---"
