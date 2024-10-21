<#
.SYNOPSIS
    Retrieves the security namespaces for a specified Azure DevOps organization.

.DESCRIPTION
    The List-DevOpsSecurityNamespaces function invokes the Azure DevOps REST API to retrieve the security namespaces for a given organization.
    It returns the namespaces if available, otherwise returns null.

.PARAMETER OrganizationName
    The name of the Azure DevOps organization for which to retrieve the security namespaces.

.EXAMPLE
    List-DevOpsSecurityNamespaces -OrganizationName "Contoso"

    This example retrieves the security namespaces for the "Contoso" Azure DevOps organization.

.NOTES
    This function uses the Invoke-AzDevOpsApiRestMethod cmdlet to make the REST API call.
#>
Function List-DevOpsSecurityNamespaces
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String]$OrganizationName
    )

    # Use a verbose statement to indicate the start of the function.
    Write-Verbose "[List-DevOpsSecurityNamespaces] Started."

    # Params
    $params = @{
        Uri = "https://dev.azure.com/$OrganizationName/_apis/securitynamespaces/"
        Method = 'Get'
    }

    # Invoke the Rest API to get the groups
    $namespaces = Invoke-AzDevOpsApiRestMethod @params

    if ($null -eq $namespaces.value)
    {
        return $null
    }

    # Return the groups from the cache
    return $namespaces.Value

}
