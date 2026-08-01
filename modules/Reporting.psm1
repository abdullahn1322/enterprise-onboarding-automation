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

function Add-MoveResult {

    param(
        [string]$UserPrincipalName,
        [string]$OldDepartment,
        [string]$NewDepartment,
        [string]$OldGroup,
        [string]$NewGroup,
        [string]$Status,
        [string]$Reason
    )

    $ProjectRoot = Split-Path $PSScriptRoot -Parent
    $ReportFolder = Join-Path $ProjectRoot "reports"

    if (!(Test-Path $ReportFolder)) {
        New-Item -ItemType Directory -Path $ReportFolder | Out-Null
    }

    $ReportFile = Join-Path $ReportFolder "MoveReport.csv"

    $Result = [PSCustomObject]@{
        Timestamp         = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        UserPrincipalName = $UserPrincipalName
        OldDepartment     = $OldDepartment
        NewDepartment     = $NewDepartment
        OldGroup          = $OldGroup
        NewGroup          = $NewGroup
        Status            = $Status
        Reason            = $Reason
    }

    $Result | Export-Csv `
        -Path $ReportFile `
        -Append `
        -NoTypeInformation `
        -Force
}