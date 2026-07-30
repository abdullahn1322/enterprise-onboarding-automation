function Get-DepartmentGroups {

    param(
        [string]$Department
    )

    switch ($Department.ToUpper()) {

        "IT" {
            Write-Host ">>> NEW GROUP MODULE LOADED <<<" -ForegroundColor Magenta
return @("SG-IT")
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

            # Retrieve all groups
            $AllGroups = Invoke-RestMethod `
                -Method GET `
                -Uri "https://graph.microsoft.com/v1.0/groups" `
                -Headers $Headers

            # Find the group by display name
            $Group = $AllGroups.value | Where-Object {
                $_.displayName -eq $GroupName
            }

            if (-not $Group) {

                Write-Host "Group '$GroupName' not found." -ForegroundColor Yellow
                continue

            }

            $GroupId = $Group.id

            Write-Host "Found Group ID: $GroupId" -ForegroundColor DarkGray

            $Body = @{
                "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$UserId"
            } | ConvertTo-Json

            Invoke-RestMethod `
                -Method POST `
                -Uri "https://graph.microsoft.com/v1.0/groups/$GroupId/members/`$ref" `
                -Headers $Headers `
                -Body $Body

            Write-Host "Adding UserId $UserId to GroupId $GroupId" -ForegroundColor Yellow

        }
        catch {

            Write-Host "Failed to assign user to '$GroupName'" -ForegroundColor Red
            Write-Host $_ -ForegroundColor DarkRed

        }

    }

}

Export-ModuleMember -Function Get-DepartmentGroups, Add-UserToGroups