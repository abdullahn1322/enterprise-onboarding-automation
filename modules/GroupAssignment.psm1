function Get-DepartmentGroups {

    param(
        [string]$Department
    )

    switch ($Department.ToUpper()) {

        "IT" {
            Write-Host ">>> NEW GROUP MODULE LOADED <<<" -ForegroundColor Magenta
            return @("SG-IT")
        }

        "HR" {
            return @("SG-HR")
        }

        default {
            return @()
        }
    }
}

function Add-UserToGroups {

    param(
        [string]$AccessToken,
        [string]$UserId,
        [string[]]$Groups
    )

    $Headers = @{
        Authorization = "Bearer $AccessToken"
        "Content-Type" = "application/json"
    }

    foreach ($GroupName in $Groups) {

        try {

            Write-Host ""
            Write-Host "Assigning group: $GroupName" -ForegroundColor Cyan

            $AllGroups = Invoke-RestMethod `
                -Method GET `
                -Uri "https://graph.microsoft.com/v1.0/groups" `
                -Headers $Headers

            $Group = $AllGroups.value | Where-Object {
                $_.displayName -eq $GroupName
            }

            if (-not $Group) {

                Write-Host "Group '$GroupName' not found." -ForegroundColor Yellow
                continue
            }

            $GroupId = $Group.id

            Write-Host "Found Group ID: $GroupId" -ForegroundColor DarkGray
            Write-Host "Adding UserId $UserId to GroupId $GroupId"

            $Body = @{
                "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$UserId"
            } | ConvertTo-Json

            Invoke-RestMethod `
                -Method POST `
                -Uri "https://graph.microsoft.com/v1.0/groups/$GroupId/members/`$ref" `
                -Headers $Headers `
                -Body $Body

            Write-Host "Added user to '$GroupName' successfully." -ForegroundColor Green
        }
        catch {

          Write-Host "User is already a member of '$GroupName'. Skipping..." -ForegroundColor Yellow

        }
    }
}

function Remove-UserFromGroup {

    param(
        [string]$AccessToken,
        [string]$UserId,
        [string]$GroupName
    )

    $Headers = @{
        Authorization = "Bearer $AccessToken"
        "Content-Type" = "application/json"
    }

    try {

        Write-Host ""
        Write-Host "Removing user from group: $GroupName" -ForegroundColor Yellow

        $AllGroups = Invoke-RestMethod `
            -Method GET `
            -Uri "https://graph.microsoft.com/v1.0/groups" `
            -Headers $Headers

        $Group = $AllGroups.value | Where-Object {
            $_.displayName -eq $GroupName
        }

        if (-not $Group) {

            Write-Host "Group '$GroupName' not found." -ForegroundColor Red
            return
        }

        Invoke-RestMethod `
            -Method DELETE `
            -Uri "https://graph.microsoft.com/v1.0/groups/$($Group.id)/members/$UserId/`$ref" `
            -Headers $Headers

        Write-Host "Removed user from '$GroupName' successfully." -ForegroundColor Green
    }
    catch {

        Write-Host "User is not a member of '$GroupName'. Skipping..." -ForegroundColor Yellow

    }
}

Export-ModuleMember -Function Get-DepartmentGroups, Add-UserToGroups, Remove-UserFromGroup