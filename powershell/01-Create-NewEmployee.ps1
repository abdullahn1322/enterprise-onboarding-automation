# ============================================
# Enterprise Onboarding Automation
# Create New Employee from CSV
# ============================================

Clear-Host

Write-Host "==============================================" -ForegroundColor Cyan
Write-Host " Enterprise Onboarding Automation" -ForegroundColor Cyan
Write-Host " Create Users in Microsoft Entra ID" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""

# ==========================================================
# Authentication
# ==========================================================

# Load Configuration
# Project Root
$ProjectRoot = Split-Path $PSScriptRoot -Parent

# Configuration File
$ConfigPath = Join-Path $ProjectRoot "config\settings.json"
$Config = Get-Content $ConfigPath | ConvertFrom-Json

# Import Password Generator Module
$ModulePath = Join-Path $ProjectRoot "modules\PasswordGenerator.psm1"
Import-Module $ModulePath
$ValidationModule = Join-Path $ProjectRoot "modules\Validation.psm1"

Import-Module $ValidationModule
$LoggingModule = Join-Path $ProjectRoot "modules\Logging.psm1"
Import-Module $LoggingModule

$ReportingModule = Join-Path $ProjectRoot "modules\Reporting.psm1"
Import-Module $ReportingModule

$GroupAssignmentModule = Join-Path $ProjectRoot "modules\GroupAssignment.psm1"
Import-Module $GroupAssignmentModule -Force

Write-Host "Loading module from: $GroupAssignmentModule" -ForegroundColor Yellow

$ManagerModule = Join-Path $ProjectRoot "modules\ManagerAssignment.psm1"
Import-Module $ManagerModule -Force

Import-Module $ValidationModule

$TenantId = $Config.TenantId
$ClientId = $Config.ClientId
$ClientSecret = $Config.ClientSecret

$Body = @{
    grant_type    = "client_credentials"
    client_id     = $ClientId
    client_secret = $ClientSecret
    scope         = "https://graph.microsoft.com/.default"
}

try {

    Write-Host "Authenticating to Microsoft Graph..." -ForegroundColor Yellow

    $TokenResponse = Invoke-RestMethod `
        -Method POST `
        -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" `
        -Body $Body `
        -ErrorAction Stop

    $AccessToken = $TokenResponse.access_token

    Write-Host "Authentication Successful!" -ForegroundColor Green
    Write-Host ""
    Write-Log `
    -Level SUCCESS `
    -Message "Authentication successful."

}
catch {

    Write-Host "Authentication Failed!" -ForegroundColor Red
    $_.Exception.Message

    if ($_.ErrorDetails.Message) {
        $_.ErrorDetails.Message
    }

    return
}

# ==========================================================
# Microsoft Graph Header
# ==========================================================

$Headers = @{
    Authorization = "Bearer $($TokenResponse.access_token)"
    "Content-Type" = "application/json"
}

# ==========================================================
# Read CSV
# ==========================================================

$CsvPath = ".\input\01-NewEmployees.csv"

if (!(Test-Path $CsvPath)) {

    Write-Host "CSV file not found!" -ForegroundColor Red
    return
}

$Users = Import-Csv $CsvPath

Write-Host "$($Users.Count) employee(s) found in CSV." -ForegroundColor Cyan
Write-Host ""

# ==========================================================
# Create Users & Groups
# ==========================================================
$DepartmentGroups = @("SG-IT")
Write-Host "DEBUG Groups: $($DepartmentGroups -join ', ')" -ForegroundColor Magenta

Write-Host "Department: $($User.Department)" -ForegroundColor Cyan

Write-Host "Groups to assign:" -ForegroundColor Cyan

$DepartmentGroups | ForEach-Object {

    Write-Host "  - $_" -ForegroundColor Gray

}

foreach ($User in $Users) {

    Write-Host "----------------------------------------" -ForegroundColor DarkGray
    Write-Host "Creating User: $($User.DisplayName)" -ForegroundColor Yellow
    Write-Host "Checking if user already exists..." -ForegroundColor Cyan
    Write-Log `
    -Level INFO `
    -Message "Checking user: $($User.UserPrincipalName)"

$UserExists = Test-UserExists `
    -UserPrincipalName $User.UserPrincipalName `
    -AccessToken $AccessToken

 Write-Log `
    -Level WARNING `
    -Message "Skipped existing user: $($User.UserPrincipalName)"

if ($UserExists) {

   Write-Host "User '$($User.DisplayName)' already exists. Skipping..." -ForegroundColor Yellow
   Add-ProvisioningResult `
    -DisplayName $User.DisplayName `
    -UserPrincipalName $User.UserPrincipalName `
    -Department $User.Department `
    -Status "Skipped" `
    -Reason "User already exists"
    continue
    Write-Log `
    -Level WARNING `
    -Message "User already exists: $($User.UserPrincipalName)"

}

    $MailNickname = ($User.UserPrincipalName -split "@")[0]

    $PasswordProfile = @{
        password = New-RandomPassword
        forceChangePasswordNextSignIn = $true
    }

    $NewUser = @{
        accountEnabled    = $true
        displayName       = $User.DisplayName
        givenName         = $User.FirstName
        surname           = $User.LastName
        userPrincipalName = $User.UserPrincipalName
        mailNickname      = $MailNickname
        department        = $User.Department
        officeLocation    = $User.OfficeLocation
        jobTitle          = $User.JobTitle
        employeeId        = $User.EmployeeID
        companyName       = $User.CompanyName
        passwordProfile   = $PasswordProfile
    }

    try {

         $CreatedUser = Invoke-RestMethod `
        -Method POST `
        -Uri "https://graph.microsoft.com/v1.0/users" `
        -Headers $Headers `
        -Body ($NewUser | ConvertTo-Json -Depth 10) `
        -ErrorAction Stop

    # Assign Security Groups
    $DepartmentGroups = Get-DepartmentGroups -Department $User.Department

    Add-UserToGroups `
        -AccessToken $AccessToken `
        -UserId $CreatedUser.id `
        -Groups $DepartmentGroups

    # Assign Manager
    Set-UserManager `
        -AccessToken $AccessToken `
        -UserId $CreatedUser.id `
        -ManagerEmail $User.ManagerEmail

    Write-Host "SUCCESS - User created successfully." -ForegroundColor Green


        Add-ProvisioningResult `
    -DisplayName $User.DisplayName `
    -UserPrincipalName $User.UserPrincipalName `
    -Department $User.Department `
    -Status "Created" `
    -Reason "Success"
        Write-Log `
    -Level SUCCESS `
    -Message "User created successfully: $($User.UserPrincipalName)"

    }
    catch {
Write-Log `
    -Level ERROR `
    -Message "Failed to create user: $($User.UserPrincipalName)"

    Add-ProvisioningResult `
    -DisplayName $User.DisplayName `
    -UserPrincipalName $User.UserPrincipalName `
    -Department $User.Department `
    -Status "Failed" `
    -Reason $_.Exception.Message

        Write-Host "FAILED - Unable to create user." -ForegroundColor Red

        if ($_.ErrorDetails.Message) {
            Write-Host ""
            Write-Host $_.ErrorDetails.Message
        }
        else {
            Write-Host $_.Exception.Message
        }
    }

    Write-Host ""
}

Write-Log `
    -Level INFO `
    -Message "Provisioning process completed."
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host " Script Completed" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Cyan