function Get-DevOpsSecurityNamespaces {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Organization,

        [Parameter(Mandatory = $false)]
        [string]$SecurityNamespaceId,

        [Parameter(Mandatory = $true)]
        [string]$PersonalAccessToken
    )

    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($PersonalAccessToken)"))

    # Construct the URI with or without the SecurityNamespaceId parameter
    $uri = if ($SecurityNamespaceId) {
        "https://dev.azure.com/$Organization/_apis/securitynamespaces/$SecurityNamespaceId?api-version=7.2-preview.1"
    } else {
        "https://dev.azure.com/$Organization/_apis/securitynamespaces?api-version=7.2-preview.1"
    }

    try {
        $response = Invoke-RestMethod -Uri $uri -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType "application/json" -Method Get

        if ($response.value) {
            Write-Output $response.value
        } else {
            Write-Output $response
        }
    } catch {
        Write-Error "Failed to retrieve security namespaces: $_"
    }
}
