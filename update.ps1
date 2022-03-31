<#
The below script will...

    1. update/install chocolatey
    2. get apps listed in a seperate text file
    3. update/install those apps
#>

# Setup Logging
$CurrentFolder = "\Chocolatey Logs\$env:COMPUTERNAME\"
$LogDir = Join-Path $PSScriptRoot $CurrentFolder
$AppList = Join-Path $PSScriptRoot "\apps.txt"

If (!(test-path $LogDir)) {New-Item $LogDir -ItemType Directory}

$LogFile = "$LogDir\chocolatey_log_$(Get-Date -UFormat "%Y-%m-%d")"


# Attempt to upgrade chocolatey (and all installed packages) else (if the command fails) install it.
try {
    choco upgrade all -y -r --no-progress --log-file=$LogFile
    } catch {
    [System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }


# Create an array from the list of apps
$AppsToInstall = @(Get-Content $AppList)

# Loop through each app and install it, will automatically skip if already installed
foreach ($App in $AppsToInstall) {
    
        choco install $App -y -r --no-progress --log-file=$LogFile
    
        }

# Remove log files over 10 days old
$limit = (Get-Date).AddDays(-10)
Get-ChildItem -Path $LogDir | Where-Object { $_.CreationTime -lt $limit } | Remove-Item -Force
