$ENV:STARSHIP_CONFIG = "$HOME\.config\starship.toml"
Invoke-Expression (&starship init powershell)

# Ensure ssh service and ssh agent are running
Start-Service ssh-agent
ssh-add

# set custom alias'
Set-Alias -Name tf -Value terraform