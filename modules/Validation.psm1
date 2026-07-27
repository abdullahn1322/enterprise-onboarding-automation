function Test-UserExists {

    param(
        [string]$UserPrincipalName,
        [string]$AccessToken
    )

    $Headers = @{
        Authorization = "Bearer $AccessToken"
    }

    $Uri = "https://graph.microsoft.com/v1.0/users/$UserPrincipalName"

    try {

        Invoke-RestMethod `
            -Uri $Uri `
            -Headers $Headers `
            -Method GET `
            -ErrorAction Stop | Out-Null

        return $true

    }
    catch {

        return $false

    }

}