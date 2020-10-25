<#
    .SYNOPSIS
        Returns a URI for the 'Azure DevOps Services' API for the provided 'OrganizationName'.

    .PARAMETER OrganizationName
        The 'OrganizationName' to obtain the 'Azure DevOps Services', API URI for.

    .EXAMPLE
        Get-AzDevOpsServicesApiUri -OrganizationName 'YourOrganizationName'

        Returns the 'Azure DevOps Services', API URI associated with the 'OrganizationName' provided.
#>
function Get-AzDevOpsServicesApiUri
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

    [System.String]$uri = Get-AzDevOpsServicesUri -OrganizationName $OrganizationName

    return $uri + "_apis"
}
