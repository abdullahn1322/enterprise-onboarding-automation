$config = Get-Content ".\config\settings.json" -Raw | ConvertFrom-Json

$Body = @{
    client_id     = $config.ClientId
    client_secret = $config.ClientSecret
    scope         = "https://graph.microsoft.com/.default"
    grant_type    = "client_credentials"
}

$TokenUrl = "https://login.microsoftonline.com/$($config.TenantId)/oauth2/v2.0/token"

Write-Host $TokenUrl

try {

    $Token = Invoke-RestMethod `
        -Method POST `
        -Uri $TokenUrl `
        -Body $Body `
        -ContentType "application/x-www-form-urlencoded"

    Write-Host ""
    Write-Host "SUCCESS" -ForegroundColor Green

    $Token.access_token.Substring(0,40)

}
catch {

    $_.Exception.Message

    if($_.ErrorDetails.Message){
        $_.ErrorDetails.Message
    }

}