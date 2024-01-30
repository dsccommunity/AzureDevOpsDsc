function Get-AzDevOpsProjects {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Organization,

        [Parameter(Mandatory = $true)]
        [string]$PersonalAccessToken,

        [Parameter(Mandatory = $false)]
        [string]$StateFilter
    )

    $encodedPAT = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($PersonalAccessToken)"))

    # Construct the URI with optional state filter
    $uri = "https://dev.azure.com/$Organization/_apis/projects"

    if ($StateFilter) {
        $uri += "?stateFilter=$StateFilter"
    }

    $uri += "&api-version=7.2-preview.1"

    try {
        $headers = @{
            Authorization = "Basic $encodedPAT"
            'Content-Type' = 'application/json'
        }

        $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get

        # Output the response which contains the list of projects
        return $response.value
    } catch {
        Write-Error "Failed to get Azure DevOps projects: $_"
    }
}
