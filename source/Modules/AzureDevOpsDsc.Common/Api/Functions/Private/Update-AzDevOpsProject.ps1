function Update-AzDevOpsProject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Organization,

        [Parameter(Mandatory = $true)]
        [string]$ProjectId, # Project ID or name

        [Parameter(Mandatory = $false)]
        [string]$NewName,

        [Parameter(Mandatory = $false)]
        [string]$Description,

        [Parameter(Mandatory = $false)]
        [string]$Visibility, # "private" or "public"

        [Parameter(Mandatory = $true)]
        [string]$PersonalAccessToken
    )

    $encodedPAT = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($PersonalAccessToken)"))
    $uri = "https://dev.azure.com/$Organization/_apis/projects/$ProjectId?api-version=7.2-preview.1"

    $body = @{}

    if ($PSBoundParameters.ContainsKey('NewName')) {
        $body['name'] = $NewName
    }

    if ($PSBoundParameters.ContainsKey('Description')) {
        $body['description'] = $Description
    }

    if ($PSBoundParameters.ContainsKey('Visibility')) {
        $body['visibility'] = $Visibility
    }

    $jsonBody = $body | ConvertTo-Json

    try {
        $headers = @{
            Authorization = "Basic $encodedPAT"
            'Content-Type' = 'application/json'
        }

        $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Patch -Body $jsonBody

        # Output the response which contains the updated project details
        return $response
    } catch {
        Write-Error "Failed to update the Azure DevOps project: $_"
    }
}
