<#
.SYNOPSIS
    Retrieves a list of DevOps groups for a specified organization.

.DESCRIPTION
    This function invokes the Azure DevOps REST API to retrieve a list of groups within a specified organization.
    It uses the provided organization name and an optional API version to make the request.

.PARAMETER Organization
    The name of the Azure DevOps organization for which to retrieve the groups.
    This parameter is mandatory.

.PARAMETER ApiVersion
    The version of the Azure DevOps API to use for the request.
    If not specified, the default API version is used.

.OUTPUTS
    System.Object
    Returns an array of groups if found, otherwise returns $null.

.EXAMPLE
    List-DevOpsGroups -Organization "myOrganization"

    This example retrieves the list of DevOps groups for the organization "myOrganization".
#>
Function List-DevOpsGroups
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
        Uri = "https://vssps.dev.azure.com/$Organization/_apis/graph/groups"
        Method = 'Get'
    }

    # Invoke the Rest API to get the groups
    $groups = Invoke-AzDevOpsApiRestMethod @params

    # Return the groups from the cache
    if ($null -eq $groups.value)
    {
        return $null
    }

    # Return the groups from the cache
    return $groups.Value

}
