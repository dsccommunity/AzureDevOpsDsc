function New-AzDevOpsProject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Organization,

        [Parameter(Mandatory = $true)]
        [string]$ProjectName,

        [Parameter(Mandatory = $true)]
        [string]$Description,

        [Parameter(Mandatory = $true)]
        [string]$Visibility, # "private" or "public"

        [Parameter(Mandatory = $true)]
        [string]$PersonalAccessToken
    )

    $encodedPAT = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($PersonalAccessToken)"))
    $uri = "https://dev.azure.com/$Organization/_apis/projects?api-version=7.2-preview.1"

    $body = @{
        name         = $ProjectName
        description  = $Description
        visibility   = $Visibility
        capabilities = @{
            versioncontrol = @{
                sourceControlType = "Git"
            }
            processTemplate = @{
                templateTypeId = "6b724908-ef14-45cf-84f8-768b5384da45" # This is the ID for the Agile process template
            }
        }
    } | ConvertTo-Json

    try {
        $headers = @{
            Authorization = "Basic $encodedPAT"
            'Content-Type' = 'application/json'
        }

        $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Post -Body $body

        # Output the response which contains the created project details
        return $response
    } catch {
        Write-Error "Failed to create the Azure DevOps project: $_"
    }
}
