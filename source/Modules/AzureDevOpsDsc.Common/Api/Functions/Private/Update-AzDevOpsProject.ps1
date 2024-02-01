<#
.SYNOPSIS
Updates an Azure DevOps project.

.DESCRIPTION
This function updates an Azure DevOps project with the specified parameters. It allows you to change the project name, description, visibility, and personal access token.

.PARAMETER Organization
The name or ID of the Azure DevOps organization.

.PARAMETER ProjectId
The ID or name of the project to update.

.PARAMETER NewName
The new name for the project.

.PARAMETER Description
The new description for the project.

.PARAMETER Visibility
The visibility of the project. Valid values are 'private' and 'public'.

.PARAMETER PersonalAccessToken
The personal access token (PAT) used for authentication.

.EXAMPLE
Update-AzDevOpsProject -Organization "contoso" -ProjectId "MyProject" -NewName "NewProjectName" -Description "Updated project description" -Visibility "public" -PersonalAccessToken "PAT"

This example updates the project named "MyProject" in the "contoso" organization. It changes the project name to "NewProjectName", updates the description, sets the visibility to "public", and uses the specified personal access token for authentication.

#>
function Update-AzDevOpsProject {
    [CmdletBinding()]
    param (
        # The name or ID of the Azure DevOps organization
        [Parameter(Mandatory)]
        [string]$Organization,

        # The ID or name of the project to update
        [Parameter(Mandatory)]
        [string]$ProjectId, # Project ID or name

        # The new name for the project
        [Parameter(Mandatory = $false)]
        [string]$NewName,

        # The new description for the project
        [Parameter(Mandatory = $false)]
        [string]$Description,

        # The visibility of the project
        [Parameter(Mandatory = $false)]
        [ValidateSet('private', 'public')]
        [string]$Visibility = 'private',

        # The personal access token (PAT) used for authentication
        [Parameter(Mandatory = $false)]
        [ValidateScript({ Test-AzDevOpsPat -Pat $_ -IsValid })]
        [string]$PersonalAccessToken
    )

    Write-Verbose "[Update-AzDevOpsProject] Updating project '$ProjectId' in organization '$Organization'"

    $body = @{}

    if ($PSBoundParameters.ContainsKey('NewName')) {
        $body.name = $NewName
    }

    if ($PSBoundParameters.ContainsKey('Description')) {
        $body.description = $Description
    }

    if ($PSBoundParameters.ContainsKey('Visibility')) {
        $body.visibility = $Visibility
    }

    # Construct the Paramters for the Invoke-AzDevOpsApiRestMethod function
    $params = @{
        Uri = "https://dev.azure.com/$Organization/_apis/projects/$ProjectId?api-version=7.2-preview.1"
        Body = $body | ConvertTo-Json
        Method = 'Patch'
        Headers = @{
            'Content-Type' = 'application/json'
        }
    }

    # Only add Authorization header if Personal Access Token is provided
    if ($PersonalAccessToken) {
        $params.headers.Authorization = "Basic {0}" -f (ConvertTo-Base64String -InputObject ":$($PersonalAccessToken)")
    }

    try {
        $response = Invoke-AvDevOpsApiRestMethod @params
    } catch {
        Write-Error "Failed to update the Azure DevOps project: $_"
    }

    # Output the response which contains the updated project details
    return $response

}
