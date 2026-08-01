function Get-GraphAccessToken {

    param(
        [string]$TenantId,
        [string]$ClientId,
        [string]$ClientSecret
    )

    $Body = @{
        client_id     = $ClientId.Trim()
        client_secret = $ClientSecret.Trim()
        scope         = "https://graph.microsoft.com/.default"
        grant_type    = "client_credentials"
    }

    $TokenUrl = "https://login.microsoftonline.com/$($TenantId.Trim())/oauth2/v2.0/token"

    Write-Host ""
    Write-Host "Authenticating to Microsoft Graph..." -ForegroundColor Cyan
    Write-Host "Token URL: $TokenUrl" -ForegroundColor DarkGray

    try {

        $Token = Invoke-RestMethod `
            -Method POST `
            -Uri $TokenUrl `
            -Body $Body `
            -ContentType "application/x-www-form-urlencoded"
         Write-Host "Access Token Length: $($Token.access_token.Length)" -ForegroundColor Cyan
        Write-Host "Authentication Successful." -ForegroundColor Green

        return $Token.access_token
    }
    catch {

        Write-Host ""
        Write-Host "Authentication Failed!" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Yellow

        if ($_.ErrorDetails.Message) {
            Write-Host $_.ErrorDetails.Message -ForegroundColor Yellow
        }

        throw
    }
}

Export-ModuleMember -Function Get-GraphAccessToken