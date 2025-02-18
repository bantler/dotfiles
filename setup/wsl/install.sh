#!/bin/bash

# To install this script run "curl -sS https://raw.githubusercontent.com/bantler/dotfiles/refs/heads/main/setup/wsl/install.sh | sudo bash"

###################################
# Prerequisites

# Update the list of packages
sudo apt-get update
sudo apt-get upgrade -y

# Install pre-requisite packages.
sudo apt-get install -y wget apt-transport-https software-properties-common

# Get the version of Ubuntu
source /etc/os-release

# Download the Microsoft repository keys
wget -q https://packages.microsoft.com/config/ubuntu/$VERSION_ID/packages-microsoft-prod.deb

# Register the Microsoft repository keys
sudo dpkg -i packages-microsoft-prod.deb

# Delete the Microsoft repository keys file
rm packages-microsoft-prod.deb

# Update the list of packages after we added packages.microsoft.com
sudo apt-get update

###################################

# Create hushlogin
echo "Creating hushlogin."
touch .hushlogin

# Create ssh key
echo "Creating SSH Key."

# Ask for passphrase input
echo "Enter a passphrase for your SSH key (or press Enter for none):"
read -s passphrase </dev/tty

sudo -u "$username" ssh-keygen -t ed25519 -f $HOME/.ssh/id_ed25519 -N "$passphrase"

# Start SSH agent and add the key
echo "Adding SSH key to SSH agent..."
eval "$(ssh-agent -s)"
ssh-add $HOME/.ssh/id_ed25519 </dev/tty

# Display the public key
echo "Your new SSH public key:"
cat $HOME/.ssh/id_ed25519.pub

read -n 1 -s -r -p "SSH Key has been generated, now copy to github then Press any key to continue with installation..." </dev/tty

# Instal yadm and clone dotfiles repo
echo "Installing yadm"
sudo apt-get install yadm
yadm clone git@github.com:bantler/dotfiles.git

# Install starship
echo "Installing starship"
curl -sS https://starship.rs/install.sh | sh

# # Install zsh shell
echo "Installing zsh shell"
sudo apt-get install zsh

# # Make zsh the default shell
echo "Changing shell to zsh"
sudo chsh -s /bin/zsh

# # Install zsh plugins
echo "Installing zsh plugins"
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions.git ~/.zsh/zsh-completions

# Install powershell
echo "Installing powershell"
sudo apt-get install powershell -y

# Install Python and venv
echo "Installing python and venv"
sudo apt-get install python3
sudo apt install python3-venv -y

echo "Installing azure-cli"
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install Terraform and TFEnv
echo "Installing Terraform and tfenv"
sudo apt-get install terraform
terraform -install-autocomplete

git clone https://github.com/tfutils/tfenv.git ~/.tfenv
echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.zprofile
sudo ln -s ~/.tfenv/bin/* /usr/local/bin

# Install cmatrix
echo "Installing cmatrix"
sudo apt-get install cmatrix -y

# Install bat
echo "Installing bat"
sudo apt-get install bat -y

# Install fzf
echo "Installing fzf"
sudo apt-get install fzf

# Install zoxide
echo "Installing zoxide"
sudo apt install zoxide

# Install eza
echo "Installing eza"
sudo apt install eza -y

# Install direnv
echo "Installing direnv"
sudo apt-get install direnv

# Install jq
echo "Installing jq"
sudo apt-get install jq -y