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
# Create Users
# ==========================================================

foreach ($User in $Users) {

    Write-Host "----------------------------------------" -ForegroundColor DarkGray
    Write-Host "Creating User: $($User.DisplayName)" -ForegroundColor Yellow
    Write-Host "Checking if user already exists..." -ForegroundColor Cyan

$UserExists = Test-UserExists `
    -UserPrincipalName $User.UserPrincipalName `
    -AccessToken $AccessToken

if ($UserExists) {

   Write-Host "User '$($User.DisplayName)' already exists. Skipping..." -ForegroundColor Yellow
    continue

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

        Invoke-RestMethod `
            -Method POST `
            -Uri "https://graph.microsoft.com/v1.0/users" `
            -Headers $Headers `
            -Body ($NewUser | ConvertTo-Json -Depth 10) `
            -ErrorAction Stop

        Write-Host "SUCCESS - User created successfully." -ForegroundColor Green
    }
    catch {

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

Write-Host "==============================================" -ForegroundColor Cyan
Write-Host " Script Completed" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Cyan