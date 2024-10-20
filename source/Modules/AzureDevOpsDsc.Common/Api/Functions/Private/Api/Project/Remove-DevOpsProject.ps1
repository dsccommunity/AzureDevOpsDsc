<#
.SYNOPSIS
Removes an Azure DevOps project.

.DESCRIPTION
The Remove-DevOpsProject function is used to remove an Azure DevOps project from the specified organization.

.PARAMETER Organization
The name or URL of the Azure DevOps organization.

.PARAMETER ProjectId
The ID or name of the project to be removed.

.EXAMPLE
Remove-DevOpsProject -Organization "MyOrganization" -ProjectId "MyProject"

This example removes the Azure DevOps project with the ID "MyProject" from the organization "MyOrganization".

#>

function Remove-DevOpsProject
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Organization,

        [Parameter(Mandatory = $true)]
        [Alias('Name')]
        [System.String]
        $ProjectId,

        [Parameter()]
        [String]
        $ApiVersion = $(Get-AzDevOpsApiVersion | Select-Object -Last 1)

    )

    Write-Verbose "[Remove-DevOpsProject] Started."

    # Define the API version to use
    $params = @{
        Uri              = "https://dev.azure.com/{0}/_apis/projects/{1}?api-version={2}" -f $Organization, $ProjectId, $ApiVersion
        Method           = "DELETE"
    }

    Write-Verbose "[Remove-DevOpsProject] Removing project $ProjectId from Azure DevOps organization $Organization"

    try
    {
        # Invoke the Azure DevOps REST API to create the project
        $response = Invoke-AzDevOpsApiRestMethod @params
        # Output the response which contains the created project details
        return $response
    } catch
    {
        Write-Error "[Remove-DevOpsProject] Failed to create the Azure DevOps project: $_"
    }

}
