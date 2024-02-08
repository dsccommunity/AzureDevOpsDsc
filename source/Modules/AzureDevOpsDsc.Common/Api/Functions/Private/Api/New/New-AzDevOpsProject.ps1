<#
.SYNOPSIS
Creates a new Azure DevOps project.

.DESCRIPTION
This function creates a new Azure DevOps project using the Azure DevOps REST API. It requires the organization name, project name, description, visibility (either "private" or "public"), and a personal access token for authentication.

.PARAMETER Organization
The name of the Azure DevOps organization.

.PARAMETER ProjectName
The name of the project to be created.

.PARAMETER Description
A brief description of the project.

.PARAMETER Visibility
The visibility of the project. Valid values are "private" or "public".

.PARAMETER PersonalAccessToken
The personal access token used for authentication.

.EXAMPLE
New-AzDevOpsProject -Organization "myorg" -ProjectName "MyProject" -Description "This is a new project" -Visibility "private" -PersonalAccessToken "mytoken"

This example creates a new private Azure DevOps project named "MyProject" with the description "This is a new project" in the organization "myorg" using the specified personal access token.

#>
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

    $params = @{
        Uri              = "https://dev.azure.com/{0}/_apis/projects?api-version={1}" -f $Organization, $ApiVersion
        Method           = "Post"
        Body             = @{
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
    }


    try {

        # Invoke the Azure DevOps REST API to create the project
        $response = Invoke-AzDevOpsApiRestMethod @params
        # Output the response which contains the created project details
        return $response

    } catch {
        Write-Error "Failed to create the Azure DevOps project: $_"
    }

}
