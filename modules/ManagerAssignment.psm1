function Set-UserManager {

    param(
        [string]$AccessToken,
        [string]$UserId,
        [string]$ManagerEmail
    )

    if ([string]::IsNullOrWhiteSpace($ManagerEmail)) {
        return
    }

    $Headers = @{
        Authorization = "Bearer $AccessToken"
        "Content-Type" = "application/json"
    }

    try {

     $Managers = Invoke-RestMethod `
    -Method GET `
    -Uri "https://graph.microsoft.com/v1.0/users" `
    -Headers $Headers

$Managers = @()
$Uri = "https://graph.microsoft.com/v1.0/users?`$top=999"

do {

    $Response = Invoke-RestMethod `
        -Method GET `
        -Uri $Uri `
        -Headers $Headers

    $Managers += $Response.value

    $Uri = $Response.'@odata.nextLink'

} while ($Uri)

$Manager = $Managers | Where-Object {
    $_.userPrincipalName.Trim().ToLower() -eq $ManagerEmail.Trim().ToLower()
} | Select-Object -First 1

Write-Host ""

if ($null -eq $Manager) {
    Write-Host "Manager '$ManagerEmail' not found." -ForegroundColor Red
    return
}


        $Body = @{
            "@odata.id" = "https://graph.microsoft.com/v1.0/users/$($Manager.id)"
        } | ConvertTo-Json

        Invoke-RestMethod `
            -Method PUT `
            -Uri "https://graph.microsoft.com/v1.0/users/$UserId/manager/`$ref" `
            -Headers $Headers `
            -Body $Body

        Write-Host "Manager assigned successfully." -ForegroundColor Green

    }
    catch {

        Write-Host "========== MANAGER ERROR ==========" -ForegroundColor Red

    Write-Host $_.Exception.Message -ForegroundColor Yellow

    Write-Host $_.InvocationInfo.PositionMessage -ForegroundColor Yellow

    if ($_.ErrorDetails.Message) {
        Write-Host $_.ErrorDetails.Message -ForegroundColor Yellow
    }

    throw
    }
}

Export-ModuleMember -Function Set-UserManager