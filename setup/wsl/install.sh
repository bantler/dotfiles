#!/bin/bash

# Update and upgrade
sudo apt-get update
sudo apt-get upgrade -y

# Set root password
sudo passwd root

# Create new user
sudo adduser bantler

# grant admin to user and make default
sudo usermod -aG sudo bantler
echo -e "[user]\ndefault=bantler" | sudo tee -a /etc/wsl.conf > /dev/null
touch ~/.hushlogin

# Create ssh key
sudo ssh-keygen -t ed25519

# Instal yadm and clone dotfiles repo
sudo apt-get install yadm
yadm clone git@github.com:bantler/dotfiles.git
yadm status

# Install zsh
sudo apt-get install zsh

# Make zsh the default shell
sudo chsh -s /bin/zsh

# Install starship
curl -sS https://starship.rs/install.sh | shell

