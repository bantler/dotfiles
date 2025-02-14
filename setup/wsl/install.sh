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

# Create ssh key
echo "Creating SSH Key."

# Ask for passphrase input
echo "Enter a passphrase for your SSH key (or press Enter for none):"
read -s passphrase </dev/tty

sudo -u "$username" ssh-keygen -t ed25519 -f /home/$username/.ssh/id_ed25519 -N "$passphrase"

# Start SSH agent and add the key
echo "Adding SSH key to SSH agent..."
eval "$(ssh-agent -s)"
ssh-add /home/$username/.ssh/id_ed25519 </dev/tty

# Display the public key
echo "Your new SSH public key:"
cat /home/$username/.ssh/id_ed25519.pub

# read -n 1 -s -r -p "SSH Key has been generated, now copy to github then Press any key to continue with installation..."
# echo "SSH Key has been generated, now copy to github then Press any ENTER to continue with installation..."
# read

# # Instal yadm and clone dotfiles repo
# sudo apt-get install yadm
# HOME=/home/$username/ yadm clone git@github.com:bantler/dotfiles.git
# yadm status

# # change user
# echo "Switching user to $username"
# su - $username

# # Set new user as default in wsl
# echo -e "[user]\ndefault=bantler" | sudo tee -a /etc/wsl.conf > /dev/null

# # Instal yadm and clone dotfiles repo
# sudo apt-get install yadm
# yadm clone git@github.com:bantler/dotfiles.git
# yadm status

# # Install zsh shell
# sudo apt-get install zsh

# # Make zsh the default shell
# sudo chsh -s /bin/zsh

# # Install zsh plugins
# git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
# git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
# git clone https://github.com/zsh-users/zsh-completions.git ~/.zsh/zsh-completions

# # Update and install dependhancies and remote so
# sudo apt-get update
# sudo apt-get install -y ca-certificates curl lsb-release wget gpg gnupg apt-transport-https software-properties-common apt-transport-https -y

# wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
# sudo dpkg -i packages-microsoft-prod.deb

# wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
# sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
# echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
# rm -f packages.microsoft.gpg

# sudo mkdir -p /etc/apt/keyrings
# curl -sLS https://packages.microsoft.com/keys/microsoft.asc |
# gpg --dearmor | sudo tee /etc/apt/keyrings/microsoft.gpg > /dev/null
# sudo chmod go+r /etc/apt/keyrings/microsoft.gpg

# AZ_DIST=$(lsb_release -cs)
# echo "Types: deb
# URIs: https://packages.microsoft.com/repos/azure-cli/
# Suites: ${AZ_DIST}
# Components: main
# Architectures: $(dpkg --print-architecture)
# Signed-by: /etc/apt/keyrings/microsoft.gpg" | sudo tee /etc/apt/sources.list.d/azure-cli.sources

# wget -O- https://apt.releases.hashicorp.com/gpg | \
# gpg --dearmor | \
# sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

# gpg --no-default-keyring \
# --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
# --fingerprint

# echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
# https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
# sudo tee /etc/apt/sources.list.d/hashicorp.list

# sudo apt-get update

# # Install starship
# curl -sS https://starship.rs/install.sh | shell

# # Install vscode
# sudo apt-get install code

# # Install powershell
# sudo apt-get install powershell -y

# # Install Python and venv
# sudo apt-get install python3
# sudo apt install python3-venv -y

# sudo apt-get install azure-cli

# # Install Terraform and TFEnv
# sudo apt-get install terraform
# terraform -install-autocomplete

# git clone https://github.com/tfutils/tfenv.git ~/.tfenv
# echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.zprofile
# sudo ln -s ~/.tfenv/bin/* /usr/local/bin

# # Install cmatrix
# sudo apt-get install cmatrix -y

# # Install bat
# sudo apt-get install bat -y

# # Install fzf
# sudo apt-get install fzf

# # Install zoxide
#  sudo apt install zoxide

#  # Install eza
# sudo apt install eza -y

# # Install direnv
# sudo apt-get install direnv

# # Install jq
# sudo apt-get install jq -y