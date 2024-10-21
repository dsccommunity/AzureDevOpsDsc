<#
.SYNOPSIS
    Retrieves a list of DevOps projects for a specified organization.

.DESCRIPTION
    This function invokes the Azure DevOps REST API to retrieve a list of projects
    for a given organization. It uses the specified API version or defaults to the
    version obtained from Get-AzDevOpsApiVersion.

.PARAMETER OrganizationName
    The name of the Azure DevOps organization for which to list projects.
    This parameter is mandatory.

.PARAMETER ApiVersion
    The version of the Azure DevOps API to use. If not specified, the default
    version is obtained from Get-AzDevOpsApiVersion.

.RETURNS
    An array of project objects if projects are found, otherwise $null.

.EXAMPLE
    $projects = List-DevOpsProjects -OrganizationName "myOrganization"
    This example retrieves the list of projects for the organization "myOrganization".

.NOTES
    This function requires the Az.DevOps module to be installed and imported.
#>

function List-DevOpsProjects
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$OrganizationName,

        [Parameter()]
        [String]
        $ApiVersion = $(Get-AzDevOpsApiVersion -Default)
    )

    $params = @{
        Uri = "https://dev.azure.com/$OrganizationName/_apis/projects"
        Method = 'Get'
    }

    # Invoke the Rest API to get the groups
    $groups = Invoke-AzDevOpsApiRestMethod @params

    if ($null -eq $groups.value)
    {
        return $null
    }

    # Return the groups from the cache
    return $groups.Value

}
