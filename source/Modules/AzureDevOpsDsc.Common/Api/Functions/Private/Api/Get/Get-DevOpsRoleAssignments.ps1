function Get-DevOpsRoleAssignments {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Organization,

        [Parameter(Mandatory = $true)]
        [string]$ProjectId,

        [Parameter(Mandatory = $true)]
        [string]$NamespaceId,

        [Parameter(Mandatory = $false)]
        [string]$SubjectDescriptor,

        [Parameter(Mandatory = $true)]
        [string]$PersonalAccessToken
    )

    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($PersonalAccessToken)"))

    $uri = "https://dev.azure.com/$Organization/_apis/AccessControlLists/$NamespaceId"

    if ($null -ne $SubjectDescriptor) {
        $uri += "?descriptors=$SubjectDescriptor"
    }

    $uri += "&api-version=7.2-preview.1"

    try {
        $response = Invoke-RestMethod -Uri $uri -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType "application/json" -Method Get

        Write-Output $response
    } catch {
        Write-Error "Failed to get role assignments: $_"
    }
}
