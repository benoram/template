#!/usr/bin/env bash

# post-create.sh
# Script to configure devcontainer after creation
# Installs additional packages and configures shells

set -euo pipefail

echo "Installing system packages..."
sudo apt-get update
sudo apt-get install -y whois wget dnsutils telnet

echo "Installing starship via homebrew..."
# Ensure Homebrew is available in the current shell
if ! command -v brew >/dev/null 2>&1; then
    if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
fi

if command -v brew >/dev/null 2>&1; then
    brew install starship
else
    echo "Homebrew not found; skipping starship installation." >&2
fi
echo "Configuring bash to use starship..."
# Ensure .bashrc exists
touch ~/.bashrc
if ! grep -qF 'eval "$(starship init bash)"' ~/.bashrc; then
    echo 'eval "$(starship init bash)"' >> ~/.bashrc
fi

echo "Configuring zsh to use starship..."
# Ensure .zshrc exists
touch ~/.zshrc
if ! grep -qF 'eval "$(starship init zsh)"' ~/.zshrc; then
    echo 'eval "$(starship init zsh)"' >> ~/.zshrc
fi

echo "Devcontainer setup complete!"
