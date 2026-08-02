#==========================================================
# Enterprise Identity Lifecycle Automation
# Employee Mover Automation
# Author: Abdullah Nazim
#==========================================================

Clear-Host
Write-Host "MOVER SCRIPT VERSION 14"

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
Write-Host " Employee Mover" -ForegroundColor Yellow
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

$CsvPath = "$PSScriptRoot\..\input\02-EmployeeTransfers.csv"

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
    $_.displayName -eq "Bassam Shaikh"
} | Select-Object -First 1

if ($null -eq $GraphUser) {
    Write-Host "User not found." -ForegroundColor Red
    continue
}
$UserId = $GraphUser.id

Write-Host "User Found: $($GraphUser.displayName)" -ForegroundColor Green


}
catch {

    Write-Host "Failed to retrieve users." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Yellow

    if ($_.ErrorDetails.Message) {
        Write-Host $_.ErrorDetails.Message -ForegroundColor Yellow
    }

    throw
}

                #----------------------------------------------------------
        # Update User Attributes
        #----------------------------------------------------------

        Write-Host ""
        Write-Host "Updating user attributes..." -ForegroundColor Cyan

        $Body = @{
            department     = $User.Department
            jobTitle       = $User.JobTitle
            officeLocation = $User.OfficeLocation
            companyName    = $User.CompanyName
        } | ConvertTo-Json

        Invoke-RestMethod `
            -Method PATCH `
            -Uri "https://graph.microsoft.com/v1.0/users/$UserId" `
            -Headers $Headers `
            -Body $Body

        Write-Host "Attributes updated successfully." -ForegroundColor Green

        #----------------------------------------------------------
        # Remove Existing Group
        #----------------------------------------------------------

        Write-Host ""
        Write-Host "Removing old security group..." -ForegroundColor Cyan

    Remove-UserFromGroup `
    -AccessToken $AccessToken `
    -UserId $UserId `
    -GroupName $User.OldGroup

        Write-Host "Old group removed." -ForegroundColor Green

        #----------------------------------------------------------
        # Add New Group
        #----------------------------------------------------------

        Write-Host ""
        Write-Host "Adding new security group..." -ForegroundColor Cyan

    Add-UserToGroups `
    -AccessToken $AccessToken `
    -UserId $UserId `
    -Groups @($User.NewGroup)

        Write-Host "New group assigned." -ForegroundColor Green

        #----------------------------------------------------------
        # Update Manager
        #----------------------------------------------------------

      Write-Host ""
    Write-Host "Updating manager..." -ForegroundColor Cyan

    Set-UserManager `
    -AccessToken $AccessToken `
    -UserId $UserId `
    -ManagerEmail $User.ManagerUPN

    Write-Host "Manager updated." -ForegroundColor Green

            #----------------------------------------------------------
        # Reporting
        #----------------------------------------------------------

        Write-Host ""
        Write-Host "Writing report..." -ForegroundColor Cyan

        $Result = [PSCustomObject]@{

            UserPrincipalName = $User.UserPrincipalName
            Department        = $User.Department
            JobTitle          = $User.JobTitle
            OfficeLocation    = $User.OfficeLocation
            Company           = $User.CompanyName
            Status            = "SUCCESS"
            TimeStamp         = Get-Date
        }

        $Result | Export-Csv `
            "$PSScriptRoot\..\reports\MoverReport.csv" `
            -Append `
            -NoTypeInformation `
            -Force

        Write-Host ""
        Write-Host "Mover completed successfully." -ForegroundColor Green

    }
    catch {

        Write-Host ""
        Write-Host "===================================" -ForegroundColor Red
        Write-Host "MOVER FAILED" -ForegroundColor Red
        Write-Host "===================================" -ForegroundColor Red

        Write-Host $_.Exception.Message -ForegroundColor Yellow

        $Failed = [PSCustomObject]@{

            UserPrincipalName = $User.UserPrincipalName
            Department        = $User.Department
            Status            = "FAILED"
            Error             = $_.Exception.Message
            TimeStamp         = Get-Date
        }

        $Failed | Export-Csv `
            "$PSScriptRoot\..\reports\MoverReport.csv" `
            -Append `
            -NoTypeInformation `
        -Force
    }

}

Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host "Employee Mover Completed Successfully" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green