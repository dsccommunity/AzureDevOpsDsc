function Test-AzDevOpsBatchPermissions {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Organization,

        [Parameter(Mandatory = $true)]
        [string]$Token,

        [Parameter(Mandatory = $true)]
        [string]$SecurityNamespaceId,

        [Parameter(Mandatory = $true)]
        [string]$TokensJsonString
    )

    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($Token)"))

    $uri = "https://dev.azure.com/$Organization/_apis/permissionsbatch?api-version=7.2-preview.1"

    $body = @{
        securityNamespaceId = $SecurityNamespaceId
        tokens             = $TokensJsonString | ConvertFrom-Json
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri $uri -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType "application/json" -Body $body -Method Post

        # Output the response or process it as needed
        $response.value | ForEach-Object {
            if ($_.hasPermission) {
                Write-Host "Permission granted for token $($_.token)" -ForegroundColor Green
            } else {
                Write-Host "Permission denied for token $($_.token)" -ForegroundColor Red
            }
        }
    } catch {
        Write-Error "Failed to check batch permissions: $_"
    }
}
