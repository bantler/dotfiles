# Enable WSL
Write-Host "Installing WSL"
wsl --install

# Install Linux distro
Write-Host "Installing Ubuntu 24.04"
wsl --install -d Ubuntu-24.04

# Download Winget configuration file
Write-Host "Downloading Winget configuration file"
Invoke-WebRequest -Uri https://raw.githubusercontent.com/bantler/dotfiles/refs/heads/main/setup/win/configuration.dsc.win11.yaml -OutFile C:\configuration.dsc.win11.yaml

# Enable Winget configure
Write-Host "Enabling Winget configure"
winget configure --Enable

# Apply Winget configuration
Write-Host "Applying winget configuration"
winget configure -f "C:\configuration.dsc.win11.yaml"

# Install NerdFonts Module
Write-Host "Installing Nerd Fonts"
Install-PSResource -Name NerdFonts
Import-Module -Name NerdFonts

#FireCode
Write-Host "Installing FireCode font"
Install-NerdFont -Name 'FiraCode' -Scope CurrentUser

# Hack Nerd Font
Write-Host "Installing Hack font"
Install-NerdFont -Name 'Hack' -Scope CurrentUser

# Config Git
Write-Host "Configuring Git"
git config --global user.email "matt.j.collin@gmail.com"
git config --global user.name "Matt Collin"
