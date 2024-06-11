function Set-DevOpsRoleAssignment {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Organization,

        [Parameter(Mandatory = $true)]
        [string]$ProjectId,

        [Parameter(Mandatory = $true)]
        [string]$NamespaceId,

        [Parameter(Mandatory = $true)]
        [string]$RoleId,

        [Parameter(Mandatory = $true)]
        [string]$UserDescriptor,

        [Parameter(Mandatory = $true)]
        [string]$PersonalAccessToken
    )

    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($PersonalAccessToken)"))

    $body = @{
        accessControlEntries = @(
            @{
                descriptor = $UserDescriptor
                role       = @{
                    id = $RoleId
                }
                allow      = 2 # This value represents "Allow" permission, change as needed
            }
        )
    } | ConvertTo-Json

    $uri = "https://dev.azure.com/$Organization/_apis/AccessControlLists/$NamespaceId?api-version=7.2-preview.1"

    try {
        $response = Invoke-RestMethod -Uri $uri -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType "application/json" -Method Post -Body $body

        Write-Output "Role assignment set successfully."
    } catch {
        Write-Error "Failed to set role assignment: $_"
    }
}
