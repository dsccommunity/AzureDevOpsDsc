function Set-DevOpsRoleAssignments {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Organization,

        [Parameter(Mandatory = $true)]
        [string]$ProjectId,

        [Parameter(Mandatory = $true)]
        [string]$NamespaceId,

        [Parameter(Mandatory = $true)]
        [string]$RoleAssignmentJson,

        [Parameter(Mandatory = $true)]
        [string]$PersonalAccessToken
    )

    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($PersonalAccessToken)"))

    $uri = "https://dev.azure.com/$Organization/_apis/AccessControlLists/$NamespaceId?api-version=7.2-preview.1"

    try {
        $response = Invoke-RestMethod -Uri $uri -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType "application/json" -Method Post -Body $RoleAssignmentJson

        Write-Output "Role assignments set successfully."
        Write-Output $response
    } catch {
        Write-Error "Failed to set role assignments: $_"
    }
}
