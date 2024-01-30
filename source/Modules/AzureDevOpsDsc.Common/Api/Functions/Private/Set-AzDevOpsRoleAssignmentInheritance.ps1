function Set-AzDevOpsRoleAssignmentInheritance {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Organization,

        [Parameter(Mandatory = $true)]
        [string]$ProjectId,

        [Parameter(Mandatory = $true)]
        [string]$NamespaceId,

        [Parameter(Mandatory = $true)]
        [bool]$InheritPermissions,

        [Parameter(Mandatory = $true)]
        [string]$PersonalAccessToken
    )

    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($PersonalAccessToken)"))

    $body = @{
        inheritPermissions = $InheritPermissions
    } | ConvertTo-Json

    $uri = "https://dev.azure.com/$Organization/$ProjectId/_apis/AccessControlEntries/$NamespaceId?api-version=7.2-preview.1"

    try {
        $response = Invoke-RestMethod -Uri $uri -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType "application/json" -Body $body -Method Patch

        Write-Output $response
    } catch {
        Write-Error "Failed to change role assignment inheritance: $_"
    }
}
