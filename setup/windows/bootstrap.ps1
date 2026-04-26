[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$WSL_DISTRO = "Ubuntu-24.04"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Check if script is running on Windows
if (-not ($env:OS -eq "Windows_NT")) {
    throw "This script must be run on Windows."
}

function Test-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p  = New-Object Security.Principal.WindowsPrincipal($id)
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-PropertyIfExists {
    param(
        [Parameter(Mandatory = $false)]
        [object]$Object,

        [Parameter(Mandatory = $true)]
        [string]$PropertyName
    )

    if ($null -eq $Object) {
        return $null
    }

    $property = $Object.PSObject.Properties[$PropertyName]
    if ($null -ne $property) {
        return $property.Value
    }

    return $null
}

if (-not (Test-Admin)) {
    Write-Host "Requesting admin privileges..."

    $elevationArgs = @(
        "-NoProfile"
        "-ExecutionPolicy Bypass"
        "-File `"$PSCommandPath`""
        "-WSL_DISTRO `"$WSL_DISTRO`""
    ) -join ' '

    Start-Process powershell.exe -Verb RunAs -ArgumentList $elevationArgs | Out-Null

    # CRITICAL: hard exit so Make doesn't hang and no duplicate logic runs
    exit 0
}

Write-Host "Running as Administrator" -ForegroundColor Green

Write-Host "" 
Write-Host "========================================================" -ForegroundColor DarkCyan
Write-Host "  Local Environment Bootstrap (Windows)" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor DarkCyan
Write-Host "This script will guide you through optional setup tasks." -ForegroundColor Gray
Write-Host "" 
Write-Host "Planned steps:" -ForegroundColor Cyan
Write-Host "  1. Install and upgrade Windows apps (Winget)." -ForegroundColor Gray
Write-Host "  2. Configure Git identity settings." -ForegroundColor Gray
Write-Host "  3. Setup OpenSSH capabilities and SSH keys." -ForegroundColor Gray
Write-Host "  4. Install/configure WSL distro: $WSL_DISTRO." -ForegroundColor Gray
Write-Host "" 
Write-Host "You will be prompted before each step runs." -ForegroundColor Yellow
Write-Host ""

# Install Windows applications via Winget
if ((Read-Host "Would you like to install Windows applications via Winget? (Y/N)")  -notin @('n','N')) {
    Write-Host "Enabling Winget configure" -ForegroundColor Cyan
    winget configure --Enable
    
    Write-Host "Applying winget configuration" -ForegroundColor Cyan
    winget configure -f "$(Split-Path -Parent $MyInvocation.MyCommand.Path)\configuration.dev.yaml"
    
    Write-Host "Upgrading all packages" -ForegroundColor Cyan
    winget upgrade --all --accept-source-agreements --accept-package-agreements

    # Add GnuWin32 to user PATH if not already present
    $pathToAdd = "C:\Program Files (x86)\GnuWin32\bin"
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")

    if ($userPath -notlike "*$pathToAdd*") {
        [Environment]::SetEnvironmentVariable("Path", "$userPath;$pathToAdd", "User")
    }
}

# Configure Git user name and email based on registry values from Microsoft Office identity information
if ((Read-Host "Would you like to configure Git user name and email? (Y/N)") -notin @('n','N')) {
    $identity = Get-ItemProperty "HKCU:\Software\Microsoft\Office\16.0\Common\Identity" -ErrorAction SilentlyContinue

    $Email = Get-PropertyIfExists -Object $identity -PropertyName "ADUserName"
    if (-not $Email) {
        $Email = Read-Host "Enter your email address"
    }

    if ($Email) {
        Write-Host "Setting Git email to $Email" -ForegroundColor Cyan
        git config --global user.email $Email *> $null
    }

    $Name = Get-PropertyIfExists -Object $identity -PropertyName "ADUserDisplayName"
    if (-not $Name) {
        $Name = Read-Host "Enter your name"
    }

    if ($Name) {
        Write-Host "Setting Git username to $Name" -ForegroundColor Cyan
        git config --global user.name $Name *> $null
    }

    Write-Host "Git configuration applied successfully." -ForegroundColor Green
}

# Configure SSH keys and OpenSSH Client/Server capabilities for Windows
if ((Read-Host "Would you like to setup SSH keys and OpenSSH Client/Server capabilities? (Y/N)") -notin @('n','N')) {
    
    Write-Host "Checking and enabling OpenSSH Client and Server Windows Capabilities if not already enabled..." -ForegroundColor Cyan
    
    $requiredCapabilities = @(
        "OpenSSH.Client~~~~0.0.1.0",
        "OpenSSH.Server~~~~0.0.1.0"
    )
    
    foreach ($capabilityName in $requiredCapabilities) {
        $capability = Get-WindowsCapability -Online | Where-Object Name -like "$capabilityName"
        
        if ($capability.State -eq "Installed") {
            Write-Host "$capabilityName is already installed" -ForegroundColor Yellow
        }
        else {
            Write-Host "$capabilityName is not enabled. Enabling now..." -ForegroundColor Green
            Add-WindowsCapability -Online -Name $capabilityName
        }
    }

    # Start the sshd service
    Write-Host "Checking sshd service status..." -ForegroundColor Cyan
    $sshdService = Get-Service -Name sshd
    if ($sshdService.Status -eq "Running") {
        Write-Host "sshd service is already running" -ForegroundColor Yellow
    }
    else {
        Write-Host "Starting sshd service..." -ForegroundColor Green
        Start-Service sshd
        Write-Host "Setting sshd service to start automatically on boot..." -ForegroundColor Green
        Set-Service -Name sshd -StartupType 'Automatic'
    }

    # Confirm the Firewall rule is configured. It should be created automatically by setup. Run the following to verify
    Write-Host "Verifying Firewall rule for OpenSSH Server (sshd)..." -ForegroundColor Cyan
    if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue)) {
        Write-Host "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..." -ForegroundColor Green
        New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
    } else {
        Write-Host "Firewall rule 'OpenSSH-Server-In-TCP' already exists." -ForegroundColor Yellow
    }

    # Ensure .ssh directory exists
    $KeyPath = Join-Path $env:USERPROFILE ".ssh"
    if (-not (Test-Path $KeyPath)) {
        New-Item -ItemType Directory -Path $KeyPath | Out-Null
    }

    # Elevated 32-bit and 64-bit sessions can resolve Windows folders differently.
    $sshKeygenCandidates = @(
        (Join-Path $env:WINDIR "System32\OpenSSH\ssh-keygen.exe"),
        (Join-Path $env:WINDIR "Sysnative\OpenSSH\ssh-keygen.exe")
    )

    $sshKeygenPath = $sshKeygenCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1

    if (-not $sshKeygenPath) {
        $sshKeygenCommand = Get-Command ssh-keygen -ErrorAction SilentlyContinue
        if ($sshKeygenCommand -and (Test-Path $sshKeygenCommand.Source)) {
            $sshKeygenPath = $sshKeygenCommand.Source
        }
    }

    if (-not $sshKeygenPath) {
        $triedLocations = $sshKeygenCandidates -join ", "
        throw "Unable to find ssh-keygen.exe in this elevated session. Checked: $triedLocations"
    }

    Write-Host "Creating SSH keys in $KeyPath" -ForegroundColor Cyan

    # Get email for current user
    $identity = Get-ItemProperty "HKCU:\Software\Microsoft\Office\16.0\Common\Identity" -ErrorAction SilentlyContinue
    $Email = Get-PropertyIfExists -Object $identity -PropertyName "ADUserName"
    if (-not $Email) {
        $Email = Read-Host "Enter your email address"
    }

    # ED25519 KEY
    $ed25519Path = Join-Path $KeyPath "id_ed25519"
    Write-Host "Generating ED25519 key..." -ForegroundColor Green
    & $sshKeygenPath -t ed25519 -C $Email -f $ed25519Path

    # RSA KEY
    $rsaPath = Join-Path $KeyPath "id_rsa"
    Write-Host "Generating RSA key (4096-bit)..." -ForegroundColor Green
    & $sshKeygenPath -t rsa -b 4096 -C $Email -f $rsaPath

    # Start SSH agent
    Write-Host "Starting SSH agent..." -ForegroundColor Cyan
    Start-Service ssh-agent -ErrorAction SilentlyContinue
    Set-Service ssh-agent -StartupType Automatic

    # # Add keys to agent
    # Write-Host "Adding keys to SSH agent..." -ForegroundColor Cyan
    # ssh-add $ed25519Path 2>$null
    # ssh-add $rsaPath 2>$null

    # Create SSH config
    $configPath = Join-Path $KeyPath "config"

    $sshHosts = @(
        @{ Comment = "Default GitHub key"; Host = "github.com"; HostName = "github.com"; IdentityFile = "~/.ssh/id_ed25519"; User = "git" }
        @{ Comment = "Azure / generic servers"; Host = "azure-*"; User = "azureuser"; IdentityFile = "~/.ssh/id_rsa" }
        @{ Host = "*"; AddKeysToAgent = "yes"; IdentitiesOnly = "yes" }
    )

    $configContent = @()
    foreach ($hostConfig in $sshHosts) {
        if ($hostConfig.ContainsKey("Comment") -and $hostConfig["Comment"]) {
            $configContent += "# $($hostConfig["Comment"])"
        }
        $configContent += "Host $($hostConfig["Host"])"
        $hostConfig.GetEnumerator() | Where-Object { $_.Key -notin @("Comment", "Host") } | ForEach-Object {
            $configContent += "$($_.Key) $($_.Value)"
        }
        $configContent += ""
    }

    $configText = $configContent -join "`n"
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($configPath, $configText, $utf8NoBom)

    Write-Host "SSH config created" -ForegroundColor Green

    # Output public keys
    Write-Host "Public keys:" -ForegroundColor Cyan
    Get-Content "$ed25519Path.pub"
    Get-Content "$rsaPath.pub"

    Write-Host "SSH environment is now configured..." -ForegroundColor Green
    Write-Host "Please add the public key(s) to your GitHub account, Azure DevOps (RSA), or other git hosting provider to enable SSH authentication." -ForegroundColor Cyan
}

if ((Read-Host "Would you like to install WSL '$WSL_DISTRO'? (Y/N)") -notin @('n','N')) {

    # Check and enable required Windows optional features.
Write-Host "Checking required Windows features are enabled..." -ForegroundColor Cyan
    $requiredFeatures = @(
        "Microsoft-Windows-Subsystem-Linux",
        "VirtualMachinePlatform"
    )
        
    foreach ($featureName in $requiredFeatures) {
        $feature = Get-WindowsOptionalFeature -Online -FeatureName $featureName

        if ($feature.State -eq "Enabled") {
            Write-Host "$featureName is already enabled" -ForegroundColor Yellow
        }
        else {
            Write-Host "$featureName is not enabled. Enabling now..." -ForegroundColor Green
            dism.exe /online /enable-feature /featurename:$featureName /all /norestart
        }
    }
    
    # Set WSL Setting default to WSL 2
    Write-Host "Setting WSL default version to 2" -ForegroundColor Cyan
    wsl --set-default-version 2

    # Set WSL Networking settings
    Write-Host "Apply configuration for wslconfig" -ForegroundColor Cyan
    $wslConfig = "$env:USERPROFILE\.wslconfig"
    $wslConfigContent = "[wsl2]`nnetworkingMode=mirrored`n[experimental]`nhostAddressLoopback=true`nbestEffortDnsParsing=true`nsparseVhd=true"
    Set-Content -Path $wslConfig -Value $wslConfigContent -Encoding ascii

    $wslDefaultUser = (Read-Host "Enter a default Linux username for '$WSL_DISTRO' (leave blank to skip)").Trim()
    if ($wslDefaultUser -and $wslDefaultUser -notmatch '^[a-z_][a-z0-9_-]*$') {
        throw "Invalid Linux username '$wslDefaultUser'. Use lowercase letters, digits, underscores, or hyphens."
    }

    # Skip installation if the distro already exists, but keep post-install setup available.
    $installedDistros = wsl --list --quiet
    $distroAlreadyInstalled = @($installedDistros | ForEach-Object { $_.Trim() }) -contains $WSL_DISTRO

    if ($distroAlreadyInstalled) {
        Write-Host "$WSL_DISTRO is already installed." -ForegroundColor Yellow
    }
    else {
        Write-Host "Proceeding with installation of $WSL_DISTRO..." -ForegroundColor Cyan
        wsl --install -d $WSL_DISTRO --no-launch

        if ($LASTEXITCODE -eq 0) {
            Write-Host "$WSL_DISTRO installation completed successfully." -ForegroundColor Green
        }
        else {
            throw "Failed to install $WSL_DISTRO. Please check the error messages above and try again."
        }
    }

    if ($wslDefaultUser) {
        Write-Host "Creating Linux user '$wslDefaultUser' in $WSL_DISTRO..." -ForegroundColor Cyan
        $createUserCommand = "id -u $wslDefaultUser >/dev/null 2>&1 || useradd -m -s /bin/bash $wslDefaultUser"
        wsl -d $WSL_DISTRO -u root -- bash -lc $createUserCommand
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to create user '$wslDefaultUser' in $WSL_DISTRO."
        }

        wsl -d $WSL_DISTRO -u root -- usermod -aG sudo $wslDefaultUser
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to add '$wslDefaultUser' to sudo group in $WSL_DISTRO."
        }

        $setDefaultUserCommand = "if [ -f /etc/wsl.conf ] && grep -q '^\[user\]' /etc/wsl.conf; then if grep -q '^default=' /etc/wsl.conf; then sed -i 's/^default=.*/default=$wslDefaultUser/' /etc/wsl.conf; else sed -i '/^\[user\]/a default=$wslDefaultUser' /etc/wsl.conf; fi; else printf '\n[user]\ndefault=$wslDefaultUser\n' >> /etc/wsl.conf; fi"
        wsl -d $WSL_DISTRO -u root -- bash -lc $setDefaultUserCommand
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to set '$wslDefaultUser' as default user in /etc/wsl.conf for $WSL_DISTRO."
        }

        if ((Read-Host "Set a password for '$wslDefaultUser' now? (Y/N)") -notin @('n','N')) {
            wsl -d $WSL_DISTRO -u root -- passwd $wslDefaultUser
            if ($LASTEXITCODE -ne 0) {
                throw "Failed to set password for '$wslDefaultUser'."
            }
        }

        Write-Host "Installing Ansible on $WSL_DISTRO..." -ForegroundColor Cyan
        wsl -d $WSL_DISTRO -u root -- bash -lc "apt-get update && apt-get install -y ansible"
        Write-Host "Ansible installed successfully on $WSL_DISTRO" -ForegroundColor Green

        Write-Host "Copying repository files to $WSL_DISTRO..." -ForegroundColor Cyan
        $src = git rev-parse --show-toplevel
        $srcWsl = wsl -d $WSL_DISTRO -u root -- wslpath -a "$src"
        if ($LASTEXITCODE -ne 0 -or -not $srcWsl) {
            throw "Failed to convert Windows repo path '$src' to a WSL path."
        }

        $srcWsl = $srcWsl.Trim()
        $destRoot = "/home/$wslDefaultUser/.automation"
        wsl -d $WSL_DISTRO -u root -- bash -lc "mkdir -p '$destRoot' && rsync -av --delete '$srcWsl/' '$destRoot/' && chown -R '${wslDefaultUser}:${wslDefaultUser}' '$destRoot'"
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to copy repository files into $WSL_DISTRO using rsync."
        }

        # # Create sudo_as_admin_successful
        # Write-Host "Creating sudo_as_admin_successful" -ForegroundColor Cyan
        # wsl -d $WSL_DISTRO -u $wslDefaultUser -- touch /home/$wslDefaultUser/.sudo_as_admin_successful

        # # Create hushlogin
        # Write-Host "Creating hushlogin." -ForegroundColor Cyan
        # wsl -d $WSL_DISTRO -u $wslDefaultUser -- touch /home/$wslDefaultUser/.hushlogin

        Write-Host "Applying user configuration by restarting $WSL_DISTRO..." -ForegroundColor Cyan
        wsl --terminate $WSL_DISTRO
        Write-Host "Default Linux user is now '$wslDefaultUser' for $WSL_DISTRO." -ForegroundColor Green
    } 
}