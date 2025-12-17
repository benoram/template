#!/usr/bin/env bash

# post-create.sh
# Script to configure devcontainer after creation
# Installs additional packages and configures shells

set -euo pipefail

echo "Installing system packages..."
sudo apt-get update
sudo apt-get install -y whois wget dnsutils telnet

echo "Installing starship via homebrew..."
brew install starship

echo "Configuring bash to use starship..."
if ! grep -q "starship init bash" ~/.bashrc; then
    echo 'eval "$(starship init bash)"' >> ~/.bashrc
fi

echo "Configuring zsh to use starship..."
if ! grep -q "starship init zsh" ~/.zshrc; then
    echo 'eval "$(starship init zsh)"' >> ~/.zshrc
fi

echo "Devcontainer setup complete!"
