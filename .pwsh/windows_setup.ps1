# Set Execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Download packages
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

# Install macchina
scoop install macchina

# Install NerdFonts Module
Install-PSResource -Name NerdFonts
Import-Module -Name NerdFonts

#FireCode
Install-NerdFont -Name 'FiraCode' -Scope CurrentUser

# Hack Nerd Font
Install-NerdFont -Name 'Hack' -Scope CurrentUser