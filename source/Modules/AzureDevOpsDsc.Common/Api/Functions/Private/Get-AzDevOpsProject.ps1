function Get-AzDevOpsProject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Organization,

        [Parameter(Mandatory = $true)]
        [string]$ProjectId,

        [Parameter(Mandatory = $true)]
        [string]$PersonalAccessToken
    )

    $encodedPAT = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($PersonalAccessToken)"))
    $uri = "https://dev.azure.com/$Organization/_apis/projects/$ProjectId?api-version=7.2-preview.1"

    try {
        $headers = @{
            Authorization = "Basic $encodedPAT"
            'Content-Type' = 'application/json'
        }

        $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get

        # Output the response which contains the project details
        return $response
    } catch {
        Write-Error "Failed to get the Azure DevOps project: $_"
    }
}
