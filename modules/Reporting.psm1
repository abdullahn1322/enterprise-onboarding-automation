function Add-ProvisioningResult {

    param(
        [string]$DisplayName,
        [string]$UserPrincipalName,
        [string]$Department,
        [string]$Status,
        [string]$Reason
    )

    $ProjectRoot = Split-Path $PSScriptRoot -Parent

    $ReportFolder = Join-Path $ProjectRoot "reports"

    if (!(Test-Path $ReportFolder)) {
        New-Item -ItemType Directory -Path $ReportFolder | Out-Null
    }

    $ReportFile = Join-Path $ReportFolder "ProvisioningReport.csv"

    $Result = [PSCustomObject]@{

        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

        DisplayName = $DisplayName

        UserPrincipalName = $UserPrincipalName

        Department = $Department

        Status = $Status

        Reason = $Reason
    }

    $Result | Export-Csv `
        -Path $ReportFile `
        -Append `
        -NoTypeInformation
}