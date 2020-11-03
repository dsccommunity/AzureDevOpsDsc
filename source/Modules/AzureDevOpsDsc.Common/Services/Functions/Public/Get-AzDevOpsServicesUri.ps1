<#
    .SYNOPSIS
        Returns a URI for 'Azure DevOps Services' for the provided 'OrganizationName'.

    .PARAMETER OrganizationName
        The 'OrganizationName' to obtain the 'Azure DevOps Services' URI for.

    .EXAMPLE
        Get-AzDevOpsServicesUri -OrganizationName 'YourOrganizationName'

        Returns the 'Azure DevOps Services' URI associated with the 'OrganizationName' provided.
#>
function Get-AzDevOpsServicesUri
{

    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateScript( { Test-AzDevOpsOrganizationName -OrganizationName $_ -IsValid })]
        [System.String]
        $OrganizationName
    )

    $OrganizationName = $OrganizationName.ToLower()

    [System.String]$uri = "https://dev.azure.com/$OrganizationName/"

    return $uri
}
