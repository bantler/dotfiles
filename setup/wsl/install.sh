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

# Install zsh shell
sudo apt-get install zsh

# Make zsh the default shell
sudo chsh -s /bin/zsh


git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions.git ~/.zsh/zsh-completions

# Install starship
curl -sS https://starship.rs/install.sh | shell

# Install apps
sudo apt-get update
sudo apt-get install -y wget gpg gnupg apt-transport-https software-properties-common apt-transport-https -y

wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
sudo dpkg -i packages-microsoft-prod.deb

wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
rm -f packages.microsoft.gpg

sudo apt-get install code
sudo apt-get install powershell -y

sudo apt-get install python3

wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt-get update
sudo apt-get install terraform
terraform -install-autocomplete

sudo apt-get install cmatrix -y

sudo apt-get install bat -y

sudo apt-get install fzf

