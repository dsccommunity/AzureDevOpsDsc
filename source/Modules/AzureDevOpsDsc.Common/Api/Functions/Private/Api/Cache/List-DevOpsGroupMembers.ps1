<#
.SYNOPSIS
Retrieves the members of a specified Azure DevOps group.

.DESCRIPTION
The List-DevOpsGroupMembers function retrieves the members of a specified Azure DevOps group by invoking the Azure DevOps REST API.
It requires the organization name and group descriptor as mandatory parameters. Optionally, an API version can be specified.

.PARAMETER Organization
The name of the Azure DevOps organization.

.PARAMETER GroupDescriptor
The descriptor of the Azure DevOps group whose members are to be retrieved.

.PARAMETER ApiVersion
The version of the Azure DevOps API to use. If not specified, the default API version is used.

.RETURNS
Returns the members of the specified Azure DevOps group. If no members are found, returns $null.

.EXAMPLE
$list = List-DevOpsGroupMembers -Organization "myOrg" -GroupDescriptor "vssgp.Uy1zNTk3NzA3LTY3NzgtNDk4NC04YjE4LTYxZDE3YjY2YjA3Nw=="
This example retrieves the members of the specified Azure DevOps group in the "myOrg" organization.

#>
function List-DevOpsGroupMembers
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Organization,
        [Parameter(Mandatory = $true)]
        [String]
        $GroupDescriptor,
        [Parameter()]
        [String]
        $ApiVersion = $(Get-AzDevOpsApiVersion -Default)
    )

    $params = @{
        Uri = 'https://vssps.dev.azure.com/{0}/_apis/graph/Memberships/{1}?direction=down' -f $Organization, $GroupDescriptor
        Method = 'Get'
    }

    #
    # Invoke the Rest API to get the groups
    $membership = Invoke-AzDevOpsApiRestMethod @params

    # Return the groups from the cache
    if ($null -eq $membership.value)
    {
        return $null
    }

    #
    # Return the groups from the cache
    return $membership.Value

}
