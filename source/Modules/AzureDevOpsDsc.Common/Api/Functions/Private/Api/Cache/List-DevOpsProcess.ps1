<#
.SYNOPSIS
    Retrieves the list of DevOps processes for a specified organization.

.DESCRIPTION
    This function invokes the Azure DevOps REST API to retrieve the list of DevOps processes for a given organization.
    It uses the specified API version or defaults to the version returned by Get-AzDevOpsApiVersion.

.PARAMETER Organization
    The name of the Azure DevOps organization for which to retrieve the processes.
    This parameter is mandatory.

.PARAMETER ApiVersion
    The version of the API to use. If not specified, the default version is used as returned by Get-AzDevOpsApiVersion.

.OUTPUTS
    System.Object
    Returns the list of DevOps processes for the specified organization.

.EXAMPLE
    List-DevOpsProcess -Organization "myOrganization"

    This example retrieves the list of DevOps processes for the organization "myOrganization" using the default API version.

.EXAMPLE
    List-DevOpsProcess -Organization "myOrganization" -ApiVersion "6.0"

    This example retrieves the list of DevOps processes for the organization "myOrganization" using API version "6.0".
#>
Function List-DevOpsProcess
{
    [CmdletBinding()]
    [OutputType([System.Object])]
    Param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $Organization,
        [Parameter()]
        [String]
        $ApiVersion = $(Get-AzDevOpsApiVersion -Default)
    )

    $params = @{
        Uri = 'https://dev.azure.com/{0}/_apis/process/processes?api-version={1}' -f $Organization, $ApiVersion
        Method = 'Get'
    }

    # Invoke the Rest API to get the groups
    $groups = Invoke-AzDevOpsApiRestMethod @params
    # Return the groups from the cache
    if ($null -eq $groups.value)
    {
        return $null
    }

    #
    # Return the groups from the cache
    return $groups.Value

}
