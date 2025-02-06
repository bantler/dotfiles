#!/bin/bash

# To install this script run "curl -sS https://raw.githubusercontent.com/bantler/dotfiles/refs/heads/main/setup/wsl/install.sh | sudo bash"

# Update and upgrade
sudo apt-get update
sudo apt-get upgrade -y

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Try using sudo."
   exit 1
fi

# Prompt user for new root password securely
echo "Enter new root password:"
read -s new_password </dev/tty

echo "Confirm new root password:"
read -s confirm_password </dev/tty

# Check if passwords match
if [[ "$new_password" != "$confirm_password" ]]; then
    echo "Error: Passwords do not match."
    exit 1
fi

# Change root password
echo "root:$new_password" | chpasswd

# Check if the password change was successful
if [[ $? -eq 0 ]]; then
    echo "Root password changed successfully."
else
    echo "Failed to change root password."
    exit 1
fi

# Prompt for username
read -p "Enter new username: " new_user

# Check if the user already exists
if id "$new_user" &>/dev/null; then
    echo "User '$new_user' already exists!"
    exit 1
fi

# Create the user
sudo adduser "$new_user"

# Prompt for sudo access
read -p "Grant sudo access to $new_user? (y/n): " sudo_access
if [[ $sudo_access == "y" ]]; then
    sudo usermod -aG sudo "$new_user"
    echo "$new_user has been added to the sudo group."
fi

echo "User $new_user created successfully."

# Create new user
#sudo adduser bantler

# grant admin to user and make default
#sudo usermod -aG sudo bantler
#echo -e "[user]\ndefault=bantler" | sudo tee -a /etc/wsl.conf > /dev/null

# change user
su - bantler

# touch hushlogin
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

# Install zsh plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions.git ~/.zsh/zsh-completions

# Update and install dependhancies and remote so
sudo apt-get update
sudo apt-get install -y ca-certificates curl lsb-release wget gpg gnupg apt-transport-https software-properties-common apt-transport-https -y

wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
sudo dpkg -i packages-microsoft-prod.deb

wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
rm -f packages.microsoft.gpg

sudo mkdir -p /etc/apt/keyrings
curl -sLS https://packages.microsoft.com/keys/microsoft.asc |
gpg --dearmor | sudo tee /etc/apt/keyrings/microsoft.gpg > /dev/null
sudo chmod go+r /etc/apt/keyrings/microsoft.gpg

AZ_DIST=$(lsb_release -cs)
echo "Types: deb
URIs: https://packages.microsoft.com/repos/azure-cli/
Suites: ${AZ_DIST}
Components: main
Architectures: $(dpkg --print-architecture)
Signed-by: /etc/apt/keyrings/microsoft.gpg" | sudo tee /etc/apt/sources.list.d/azure-cli.sources

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

# Install starship
curl -sS https://starship.rs/install.sh | shell

# Install vscode
sudo apt-get install code

# Install powershell
sudo apt-get install powershell -y

# Install Python and venv
sudo apt-get install python3
sudo apt install python3-venv -y

sudo apt-get install azure-cli

# Install Terraform and TFEnv
sudo apt-get install terraform
terraform -install-autocomplete

git clone https://github.com/tfutils/tfenv.git ~/.tfenv
echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.zprofile
sudo ln -s ~/.tfenv/bin/* /usr/local/bin

# Install cmatrix
sudo apt-get install cmatrix -y

# Install bat
sudo apt-get install bat -y

# Install fzf
sudo apt-get install fzf

# Install zoxide
 sudo apt install zoxide

 # Install eza
sudo apt install eza -y

# Install direnv
sudo apt-get install direnv

# Install jq
sudo apt-get install jq -y