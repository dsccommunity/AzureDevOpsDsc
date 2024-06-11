function Remove-DevOpsRoleAssignment {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Organization,

        [Parameter(Mandatory = $true)]
        [string]$ProjectId,

        [Parameter(Mandatory = $true)]
        [string]$NamespaceId,

        [Parameter(Mandatory = $true)]
        [string]$RoleAssignmentId,

        [Parameter(Mandatory = $true)]
        [string]$PersonalAccessToken
    )

    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($PersonalAccessToken)"))

    $uri = "https://dev.azure.com/$Organization/$ProjectId/_apis/AccessControlLists/$NamespaceId"

    if ($null -ne $RoleAssignmentId) {
        $uri += "/$RoleAssignmentId"
    }

    $uri += "?api-version=7.2-preview.1"

    try {
        $response = Invoke-RestMethod -Uri $uri -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType "application/json" -Method Delete

        Write-Output "Role assignment removed successfully."
    } catch {
        Write-Error "Failed to remove role assignment: $_"
    }
}
