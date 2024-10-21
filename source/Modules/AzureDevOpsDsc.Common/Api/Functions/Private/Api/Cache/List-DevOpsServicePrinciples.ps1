<#
.SYNOPSIS
Retrieves a list of service principals from an Azure DevOps organization.

.DESCRIPTION
The List-DevOpsServicePrinciples function calls the Azure DevOps REST API to retrieve a list of service principals for a specified organization. The function requires the organization name and optionally accepts an API version.

.PARAMETER OrganizationName
The name of the Azure DevOps organization from which to retrieve the service principals. This parameter is mandatory.

.PARAMETER ApiVersion
The version of the Azure DevOps API to use. If not specified, the default API version is used.

.EXAMPLE
PS> List-DevOpsServicePrinciples -OrganizationName "myOrganization"

This example retrieves the list of service principals for the organization named "myOrganization".

.EXAMPLE
PS> List-DevOpsServicePrinciples -OrganizationName "myOrganization" -ApiVersion "6.0"

This example retrieves the list of service principals for the organization named "myOrganization" using API version "6.0".

.RETURNS
The function returns a list of service principals if available; otherwise, it returns $null.

#>
Function List-DevOpsServicePrinciples
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
        Uri = "https://vssps.dev.azure.com/$OrganizationName/_apis/graph/serviceprincipals"
        Method = 'Get'
    }

    #
    # Invoke the Rest API to get the groups
    $serviceprincipals = Invoke-AzDevOpsApiRestMethod @params

    if ($null -eq $serviceprincipals.value)
    {
        return $null
    }

    # Return the groups from the cache
    return $serviceprincipals.Value

}
