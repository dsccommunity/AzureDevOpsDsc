<#
.SYNOPSIS
Retrieves the list of users from the Azure DevOps organization.

.DESCRIPTION
The List-UserCache function invokes the Azure DevOps REST API to retrieve the list of users
for a specified organization. It uses the provided organization name and an optional API version
to make the request. If no API version is specified, it defaults to the version returned by
the Get-AzDevOpsApiVersion function.

.PARAMETER OrganizationName
Specifies the name of the Azure DevOps organization from which to retrieve the list of users.
This parameter is mandatory.

.PARAMETER ApiVersion
Specifies the version of the Azure DevOps API to use. If not provided, the default version
returned by the Get-AzDevOpsApiVersion function is used.

.RETURNS
Returns the list of users from the specified Azure DevOps organization. If no users are found,
returns $null.

.EXAMPLE
PS> List-UserCache -OrganizationName "myOrganization"
Retrieves the list of users from the "myOrganization" Azure DevOps organization using the default API version.

.EXAMPLE
PS> List-UserCache -OrganizationName "myOrganization" -ApiVersion "6.0"
Retrieves the list of users from the "myOrganization" Azure DevOps organization using API version 6.0.
#>
function List-UserCache
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
        Uri = "https://vssps.dev.azure.com/$OrganizationName/_apis/graph/users"
        Method = 'Get'
    }

    # Invoke the Rest API to get the groups
    $users = Invoke-AzDevOpsApiRestMethod @params

    if ($null -eq $users.value)
    {
        return $null
    }

    # Return the groups from the cache
    return $users.Value

}
