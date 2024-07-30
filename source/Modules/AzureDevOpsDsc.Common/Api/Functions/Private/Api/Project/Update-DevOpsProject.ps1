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
Update-DevOpsProject -Organization "contoso" -ProjectId "MyProject" -NewName "NewProjectName" -Description "Updated project description" -Visibility "public" -PersonalAccessToken "PAT"

This example updates the project named "MyProject" in the "contoso" organization. It changes the project name to "NewProjectName", updates the description, sets the visibility to "public", and uses the specified personal access token for authentication.

#>
function Update-DevOpsProject
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Organization,

        [Parameter()]
        [Alias('Name')]
        [System.String]
        $ProjectId,

        [Parameter()]
        [Alias('Description')]
        [System.String]
        $ProjectDescription,

        [Parameter()]
        [System.String]$ProcessTemplateId,

        [Parameter()]
        [System.String]$Visibility

    )

    Write-Verbose "[Update-DevOpsProject] Updating project '$ProjectId' in organization '$Organization'"

    # Construct the body of the request
    $body = @{
        name = $ProjectName
        visibility = $Visibility
        capabilities = @{
            processTemplate = @{
                templateTypeId = $ProcessTemplateId
            }
        }
    }

    # Add the description if provided
    if ($ProjectDescription)
    {
        $body.description = $ProjectDescription
    }

    # Construct the Paramters for the Invoke-AzDevOpsApiRestMethod function
    $params = @{
        Uri = "https://dev.azure.com/$Organization/_apis/projects/$ProjectId?api-version=7.2-preview.1"
        Body = $body | ConvertTo-Json
        Method = 'PATCH'
        Headers = @{
            'Content-Type' = 'application/json'
        }
    }

    # Invoke the Azure DevOps REST API to update the project
    try
    {
        $response = Invoke-AvDevOpsApiRestMethod @params
    } catch
    {
        Write-Error "Failed to update the Azure DevOps project: $_"
    }

    # Output the response which contains the updated project details
    return $response

}
