function Write-Log {

    param(
        [string]$Message,
        [ValidateSet("INFO","SUCCESS","WARNING","ERROR")]
        [string]$Level = "INFO"
    )

    $LogFolder = Join-Path (Split-Path $PSScriptRoot -Parent) "logs"

    if (!(Test-Path $LogFolder)) {
        New-Item -ItemType Directory -Path $LogFolder | Out-Null
    }

    $LogFile = Join-Path $LogFolder "Provisioning.log"

    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    Add-Content -Path $LogFile -Value "$Timestamp [$Level] $Message"
}
