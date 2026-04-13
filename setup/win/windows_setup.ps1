# # Enable WSL
# Write-Host "Installing WSL"
# wsl --install

# # Install Linux distro
# Write-Host "Installing Ubuntu 24.04"
# wsl --install -d Ubuntu-24.04

# # Download Winget configuration file
# Write-Host "Downloading Winget configuration file"
# Invoke-WebRequest -Uri https://raw.githubusercontent.com/bantler/dotfiles/refs/heads/main/setup/win/configuration.dsc.dev.yaml -OutFile C:\configuration.dsc.dev.yaml

# Install Windows applications via Winget
if ((Read-Host "Install Windows applications via Winget? (Y/N)") -notin @('n','N')) {
    Write-Host "Enabling Winget configure"
    winget configure --Enable
    
    Write-Host "Applying winget configuration"
    winget configure -f "$(Split-Path -Parent $MyInvocation.MyCommand.Path)\configuration.dev.yaml"
    
    Write-Host "Upgrading all packages"
    winget upgrade --all --accept-source-agreements --accept-package-agreements
}

# Add GnuWin32 to PATH
$pathToAdd = "C:\Program Files (x86)\GnuWin32\bin"
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")

if ($userPath -notlike "*$pathToAdd*") {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;$pathToAdd", "User")
}

# # Install NerdFonts Module
# Write-Host "Installing Nerd Fonts"
# Install-PSResource -Name NerdFonts
# Import-Module -Name NerdFonts

# #FireCode
# Write-Host "Installing FireCode font"
# Install-NerdFont -Name 'FiraCode' -Scope CurrentUser

# # Hack Nerd Font
# Write-Host "Installing Hack font"
# Install-NerdFont -Name 'Hack' -Scope CurrentUser

# # Config Git
# Write-Host "Configuring Git"
# $username = $env:USERNAME
# $email = (Get-ChildItem 'HKCU:\Software\Microsoft\Office\*\Common\Identity' -ErrorAction SilentlyContinue | Get-ItemProperty -Name UserEmail -ErrorAction SilentlyContinue).UserEmail

# git config --global user.email $email
# git config --global user.name $username
