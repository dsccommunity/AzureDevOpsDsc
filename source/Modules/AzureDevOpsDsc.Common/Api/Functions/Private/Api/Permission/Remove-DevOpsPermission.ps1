function Remove-DevOpsPermission {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Organization,

        [Parameter(Mandatory = $true)]
        [string]$ProjectId,

        [Parameter(Mandatory = $true)]
        [string]$SecurityNamespaceId,

        [Parameter(Mandatory = $true)]
        [string]$Token,

        [Parameter(Mandatory = $true)]
        [int]$DescriptorIdentityId,

        [Parameter(Mandatory = $true)]
        [int]$PermissionBit,

        [Parameter(Mandatory = $true)]
        [string]$PersonalAccessToken
    )

    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($PersonalAccessToken)"))

    $uri = "https://dev.azure.com/$Organization/_apis/permissions/$SecurityNamespaceId/$Token?descriptorIdentityId=$DescriptorIdentityId&permissions=$PermissionBit&api-version=7.2-preview.1"

    try {
        $response = Invoke-RestMethod -Uri $uri -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType "application/json" -Method Delete

        if ($response) {
            Write-Host "Permission removed successfully." -ForegroundColor Green
        }
    } catch {
        Write-Error "Failed to remove permission: $_"
    }
}
