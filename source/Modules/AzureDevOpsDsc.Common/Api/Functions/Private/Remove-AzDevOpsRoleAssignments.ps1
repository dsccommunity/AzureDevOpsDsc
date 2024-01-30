function Remove-AzDevOpsRoleAssignments {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Organization,

        [Parameter(Mandatory = $true)]
        [string]$ProjectId,

        [Parameter(Mandatory = $true)]
        [string]$NamespaceId,

        [Parameter(Mandatory = $true)]
        [string]$TokenIds, # Comma-separated list of user descriptor tokens

        [Parameter(Mandatory = $true)]
        [string]$RoleIds, # Comma-separated list of role IDs

        [Parameter(Mandatory = $true)]
        [string]$PersonalAccessToken
    )

    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($PersonalAccessToken)"))

    $body = @{
        tokenIds  = $TokenIds.Split(',')
        roleIds   = $RoleIds.Split(',')
    } | ConvertTo-Json

    $uri = "https://dev.azure.com/$Organization/_apis/AccessControlLists/$NamespaceId/removeassignments?api-version=7.2-preview.1"

    try {
        $response = Invoke-RestMethod -Uri $uri -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType "application/json" -Method Post -Body $body

        Write-Output "Role assignments removed successfully."
    } catch {
        Write-Error "Failed to remove role assignments: $_"
    }

}
