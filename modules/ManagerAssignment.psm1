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

        $Manager = Invoke-RestMethod `
            -Method GET `
            -Uri "https://graph.microsoft.com/v1.0/users/$ManagerEmail" `
            -Headers $Headers

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

        Write-Host "Manager assignment failed." -ForegroundColor Red
        Write-Host $_.Exception.Message

    }

}

Export-ModuleMember -Function Set-UserManager