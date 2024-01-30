function Test-AzDevOpsPermission {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Organization,

        [Parameter(Mandatory = $true)]
        [string]$ProjectId,

        [Parameter(Mandatory = $true)]
        [string]$Token,

        [Parameter(Mandatory = $true)]
        [int]$NamespaceId,

        [Parameter(Mandatory = $true)]
        [int]$TokenId,

        [Parameter(Mandatory = $true)]
        [int]$Permissions,

        [Parameter(Mandatory = $true)]
        [bool]$AlwaysAllowAdministrators
    )

    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($Token)"))

    $uri = "https://dev.azure.com/$Organization/_apis/permissions/$NamespaceId/$TokenId?permissions=$Permissions&alwaysAllowAdministrators=$AlwaysAllowAdministrators&api-version=7.2-preview.1"

    try {
        $response = Invoke-RestMethod -Uri $uri -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Method Get

        if ($response.value -eq $true) {
            Write-Host "Permission granted" -ForegroundColor Green
        } else {
            Write-Host "Permission denied" -ForegroundColor Red
        }
    } catch {
        Write-Error "Failed to check permissions: $_"
    }
}
