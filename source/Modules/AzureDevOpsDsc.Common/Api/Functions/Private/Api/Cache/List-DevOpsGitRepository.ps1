<#
.SYNOPSIS
Retrieves a list of Git repositories from an Azure DevOps project.

.DESCRIPTION
The List-DevOpsGitRepository function invokes the Azure DevOps REST API to retrieve a list of Git repositories for a specified organization and project. The function returns the list of repositories if available.

.PARAMETER OrganizationName
Specifies the name of the Azure DevOps organization. This parameter is mandatory.

.PARAMETER ProjectName
Specifies the name of the Azure DevOps project. This parameter is mandatory.

.PARAMETER ApiVersion
Specifies the API version to use when making the request. If not provided, the default API version is used.

.RETURNS
Returns a list of Git repositories if available; otherwise, returns $null.

.EXAMPLE
PS> List-DevOpsGitRepository -OrganizationName "MyOrg" -ProjectName "MyProject"

.NOTES
This function requires the Azure DevOps module to be installed and configured.
#>

function List-DevOpsGitRepository
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$OrganizationName,

        [Parameter(Mandatory = $true)]
        [String]$ProjectName,

        [Parameter()]
        [String]
        $ApiVersion = $(Get-AzDevOpsApiVersion -Default)
    )

    $params = @{
        Uri = "https://dev.azure.com/$OrganizationName/$ProjectName/_apis/git/repositories"
        Method = 'Get'
    }

    # Invoke the Rest API to get the groups
    $repositories = Invoke-AzDevOpsApiRestMethod @params

    # Return the groups from the cache
    if ($null -eq $repositories.value)
    {
        return $null
    }

    #
    # Return the groups from the cache
    return $repositories.Value

}
