#==========================================================
# Enterprise Identity Lifecycle Automation
# Employee Leaver Automation
# Author: Abdullah Nazim
#==========================================================

Clear-Host

$ErrorActionPreference = "Stop"

#----------------------------------------------------------
# Import Modules
#----------------------------------------------------------

Import-Module "$PSScriptRoot\..\modules\Authentication.psm1" -Force
Import-Module "$PSScriptRoot\..\modules\GroupAssignment.psm1" -Force
Import-Module "$PSScriptRoot\..\modules\ManagerAssignment.psm1" -Force
Import-Module "$PSScriptRoot\..\modules\Logging.psm1" -Force
Import-Module "$PSScriptRoot\..\modules\Reporting.psm1" -Force

#----------------------------------------------------------
# Banner
#----------------------------------------------------------

Write-Host ""
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host " Enterprise Identity Lifecycle Automation" -ForegroundColor Cyan
Write-Host " Employee Leaver" -ForegroundColor Yellow
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""

#----------------------------------------------------------
# Authenticate
#----------------------------------------------------------

Write-Host "Authenticating with Microsoft Graph..." -ForegroundColor Yellow

#----------------------------------------------------------
# Load Configuration
#----------------------------------------------------------

$config = Get-Content "$PSScriptRoot\..\config\settings.json" -Raw | ConvertFrom-Json

$TenantId = $config.TenantId
$ClientId = $config.ClientId
$ClientSecret = $config.ClientSecret

#----------------------------------------------------------
# Authenticate
#----------------------------------------------------------

$AccessToken = Get-GraphAccessToken `
    -TenantId $TenantId `
    -ClientId $ClientId `
    -ClientSecret $ClientSecret

$Headers = @{
    Authorization = "Bearer $AccessToken"
    "Content-Type" = "application/json"
}

Write-Host "Authentication Successful." -ForegroundColor Green
Write-Host ""

#----------------------------------------------------------
# CSV Path
#----------------------------------------------------------

$CsvPath = "$PSScriptRoot\..\input\03-EmployeeLeavers.csv"

if (!(Test-Path $CsvPath))
{
    Write-Host "CSV file not found." -ForegroundColor Red
    exit
}

$Employees = Import-Csv $CsvPath

Write-Host "Employees to process : $($Employees.Count)" -ForegroundColor Cyan
Write-Host ""

#----------------------------------------------------------
# Start Processing
#----------------------------------------------------------

foreach ($User in $Employees)
{

    Write-Host "------------------------------------------" -ForegroundColor DarkGray
    Write-Host "Processing : $($User.UserPrincipalName)" -ForegroundColor Yellow

    try
    {

      $UPN = $User.UserPrincipalName.Trim()
      

Write-Host "Searching user..." -ForegroundColor Cyan

try {

    $AllUsers = @()
    $Uri = "https://graph.microsoft.com/v1.0/users?`$top=999"

    do {

        $Response = Invoke-RestMethod `
            -Method GET `
            -Uri $Uri `
            -Headers $Headers

        $AllUsers += $Response.value

        $Uri = $Response.'@odata.nextLink'

    } while ($Uri)

 
   $GraphUser = $AllUsers | Where-Object {
    $_.userPrincipalName.Trim().ToLower() -eq $UPN.Trim().ToLower()
} | Select-Object -First 1

if ($null -eq $GraphUser) {
    Write-Host "User not found." -ForegroundColor Red
    continue
}
$UserId = $GraphUser.id

Write-Host "User Found: $($GraphUser.displayName)" -ForegroundColor Green
Write-Host ""
Write-Host "Disabling user account..." -ForegroundColor Cyan

$DisableBody = @{
    accountEnabled = $false
} | ConvertTo-Json

Invoke-RestMethod `
    -Method PATCH `
    -Uri "https://graph.microsoft.com/v1.0/users/$UserId" `
    -Headers $Headers `
    -Body $DisableBody

Write-Host "User account disabled successfully." -ForegroundColor Green
Write-Host ""
Write-Host "Revoking sign-in sessions..." -ForegroundColor Cyan

$RevokeResponse = Invoke-RestMethod `
    -Method POST `
    -Uri "https://graph.microsoft.com/v1.0/users/$UserId/revokeSignInSessions" `
    -Headers $Headers

Write-Host "Sign-in sessions revoked successfully." -ForegroundColor Green
Write-Host ""
Write-Host "Removing user from security group..." -ForegroundColor Cyan

Remove-UserFromGroup `
    -AccessToken $AccessToken `
    -UserId $UserId `
    -GroupName "SG-HR"

Write-Host "Security group removed successfully." -ForegroundColor Green

}
catch {

    Write-Host $_.Exception.Message -ForegroundColor Red

}

}
catch {

    Write-Host $_.Exception.Message -ForegroundColor Red

}

}

Add-LeaverResult `
    -UserPrincipalName $User.UserPrincipalName `
    -DisplayName $GraphUser.DisplayName `
    -AccountDisabled "Yes" `
    -SessionsRevoked "Yes" `
    -GroupsRemoved "SG-HR" `
    -Status "SUCCESS" `
    -Reason "Employee Offboarding Completed"

Write-Host ""
Write-Host "==============================================" -ForegroundColor Green
Write-Host "Employee Leaver Completed Successfully" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Green

Write-Log `
    -Level SUCCESS `
    -Message "Employee Leaver completed successfully for $($User.UserPrincipalName). Account disabled, sessions revoked, removed from SG-HR."