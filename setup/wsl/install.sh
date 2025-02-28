#!/bin/bash

# To install this script run "curl -sS https://raw.githubusercontent.com/bantler/dotfiles/refs/heads/main/setup/wsl/install.sh | sudo bash"

###################################
# Prerequisites

# Update the list of packages
sudo apt-get update
sudo apt-get upgrade -y

# Install pre-requisite packages.
sudo apt-get install -y wget apt-transport-https software-properties-common gnupg software-properties-common

# Get the version of Ubuntu
source /etc/os-release

# Download the Microsoft repository keys
wget -q https://packages.microsoft.com/config/ubuntu/$VERSION_ID/packages-microsoft-prod.deb

# Register the Microsoft repository keys
sudo dpkg -i packages-microsoft-prod.deb

# Delete the Microsoft repository keys file
rm packages-microsoft-prod.deb

# Install the HashiCorp GPG key
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

# Verify the key's fingerprint
gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint

# Add offical hasicorp repositories
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

# Update all packages
sudo apt-get update

###################################

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
echo "Enter new username"
read -s username </dev/tty

echo "Enter password for $username: "
read -s password </dev/tty

# Check if the user already exists
if id "$username" &>/dev/null; then
    echo "User '$username' already exists!"
fi

# Create the user
sudo useradd -m -s /bin/bash "$username"

# Change user password
echo "$username:$password" | sudo chpasswd

# Prompt for sudo access
read -p "Grant sudo access to $username? (y/n): " sudo_access </dev/tty
if [[ $sudo_access == "y" ]]; then
    sudo usermod -aG sudo "$username"
    echo "$username has been added to the sudo group."
fi

echo "User $username created successfully."

# Create hushlogin
echo "Creating hushlogin."
touch /home/$username/.hushlogin

# # Create ssh key
# echo "Creating SSH Key."

# # Ask for passphrase input
# echo "Enter a passphrase for your SSH key (or press Enter for none):"
# read -s passphrase </dev/tty

# sudo -u "$username" ssh-keygen -t ed25519 -f /home/$username/.ssh/id_ed25519 -N "$passphrase"

# # Start SSH agent and add the key
# echo "Adding SSH key to SSH agent..."
# eval "$(ssh-agent -s)"
# ssh-add /home/$username/.ssh/id_ed25519 </dev/tty

# # Display the public key
# echo "Your new SSH public key:"
# cat /home/$username/.ssh/id_ed25519.pub

# read -n 1 -s -r -p "SSH Key has been generated, now copy to github then Press any key to continue with installation..." </dev/tty

echo "Copy ssh key from windows"
cp -r /mnt/c/Users/$username/.ssh ~/.ssh

echo "Install keychain"
sudo apt-get install keychain

# Instal yadm and clone dotfiles repo
echo "Installing yadm"
sudo apt-get install yadm
HOME=/home/$username/ yadm clone git@github.com:bantler/dotfiles.git -f

# Install starship
echo "Installing starship"
curl -sS https://starship.rs/install.sh | sh

# Install powershell
echo "Installing powershell"
sudo apt-get install powershell -y

# Install Python and venv
echo "Installing python and venv"
sudo apt-get install python3
sudo apt install python3-venv -y

echo "Installing azure-cli"
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install Terraform and tfenv
echo "Installing Terraform and tfenv"
sudo apt-get install terraform

echo "Cloning tfenv"
sudo git clone --depth=1 https://github.com/tfutils/tfenv.git /home/$username/.tfenv

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

# # Install zsh shell
echo "Installing zsh shell"
sudo apt-get install zsh

# # Install zsh plugins
echo "Installing zsh plugins"
git clone https://github.com/zsh-users/zsh-autosuggestions /home/$username/.zsh/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /home/$username/.zsh/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions.git /home/$username/.zsh/zsh-completions

# # Make zsh the default shell
echo "Changing shell to zsh"
chsh -s $(which zsh)