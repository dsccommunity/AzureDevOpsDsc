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
New-DevOpsProject -Organization "myorg" -ProjectName "MyProject" -Description "This is a new project" -Visibility "private" -PersonalAccessToken "mytoken"

This example creates a new private Azure DevOps project named "MyProject" with the description "This is a new project" in the organization "myorg" using the specified personal access token.

#>
function New-DevOpsProject
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Organization,

        [Parameter()]
        [ValidateScript({ Test-AzDevOpsProjectName -ProjectName $_ -IsValid -AllowWildcard })]
        [Alias('Name')]
        [System.String]
        $ProjectName,

        [Parameter()]
        [Alias('Description')]
        [System.String]
        $ProjectDescription,

        [Parameter()]
        [System.String]
        $SourceControlType,

        [Parameter()]
        [System.String]$ProcessTemplateId,

        [Parameter()]
        [System.String]$Visibility,

        # Get the latest API version. 7.1 is not supported by the API endpoint.
        [Parameter()]
        [String]
        $ApiVersion = $(Get-AzDevOpsApiVersion | Select-Object -Last 1)

    )

    # Validate the parameters
    $params = @{
        Uri              = "https://dev.azure.com/{0}/_apis/projects?api-version={1}" -f $Organization, $ApiVersion
        Method           = "POST"
        Body             = @{
            name         = $ProjectName
            description  = $ProjectDescription
            visibility   = $Visibility
            capabilities = @{
                versioncontrol = @{
                    sourceControlType = $SourceControlType
                }
                processTemplate = @{
                    templateTypeId = $ProcessTemplateId
                }
            }
        }
    }

    # Seralize the Body to JSON
    $params.Body = $params.Body | ConvertTo-Json

    try
    {
        # Invoke the Azure DevOps REST API to create the project
        $response = Invoke-AzDevOpsApiRestMethod @params

        if ($null -eq $response) {
            Throw "[New-DevOpsProject] Failed to create the Azure DevOps project: No response returned"
        }

        # Output the response which contains the created project details
        return $response
    } catch
    {
        Write-Error "[New-DevOpsProject] Failed to create the Azure DevOps project: $_"
    }

}
