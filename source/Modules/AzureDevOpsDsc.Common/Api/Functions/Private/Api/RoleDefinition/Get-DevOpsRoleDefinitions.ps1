function Get-DevOpsRoleDefinitions {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Organization,

        [Parameter(Mandatory = $true)]
        [string]$ProjectId,

        [Parameter(Mandatory = $true)]
        [string]$NamespaceId,

        [Parameter(Mandatory = $true)]
        [string]$PersonalAccessToken
    )

    $encodedPAT = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($PersonalAccessToken)"))

    $uri = "https://dev.azure.com/$Organization/$ProjectId/_apis/securityroles/scopes/$NamespaceId/roledefinitions?api-version=7.2-preview.1"

    try {
        $headers = @{
            Authorization = "Basic $encodedPAT"
        }

        $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get

        Write-Output "Role definitions retrieved successfully."
        return $response.value
    } catch {
        Write-Error "Failed to retrieve role definitions: $_"
    }
}
