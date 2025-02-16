# Set Execution Policy
Set-ExecutionPolicy Unrestricted
Write-Host "Execution policy set to Unrestricted"

# Install NerdFonts Module
Install-PSResource -Name NerdFonts
Import-Module -Name NerdFonts
Write-Host "Nerd Fonts installed"

#FireCode
Install-NerdFont -Name 'FiraCode' -Scope CurrentUser
Write-Host "FireCode font installed"

# Hack Nerd Font
Install-NerdFont -Name 'Hack' -Scope CurrentUser
Write-Host "Hack font installed"

# Enable WSL
wsl --install
Write-Host "WSL installed"

# Download Winget configuration file
Invoke-WebRequest -Uri https://raw.githubusercontent.com/bantler/dotfiles/refs/heads/main/setup/win/configuration.dsc.win11.yaml -OutFile C:\configuration.dsc.win11.yaml
Write-Host "Winget configuration file downloaded"

# Enable Winget configure
winget configure --Enable
Write-Host "Winget configure enabled"

# Apply Winget configuration
winget configure -f "C:\configuration.dsc.win11.yaml"
Write-Host "Apply winget configuration"