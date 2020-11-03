<#
    .SYNOPSIS
        Returns an array of all the Azure DevOps API, URI-specific, 'Area' names that can used/managed.

    .EXAMPLE
        Get-AzDevOpsApiUriAreaName

        Returns all the names of the URI-specific, area names that can be used/managed in the Azure DevOps API.

    .EXAMPLE
        Get-AzDevOpsApiUriAreaName -ResourceName 'YourResourceNameHere'

        Returns the URI-specific, resource name that can be used/managed in the Azure DevOps API for the given
        'ResourceName' (e.g. 'Project' or 'Operation')
#>
function Get-AzDevOpsApiUriAreaName
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter()]
        [ValidateScript({ Test-AzDevOpsApiResourceName -ResourceName $_ -IsValid })]
        [System.String]
        $ResourceName
    )

    [hashtable]$resourceNameToApiUriAreaName = @{

        Operation = 'core' # Note: Not explicitly listed here in documentation
        Project = 'core'
    }

    if (![string]::IsNullOrWhiteSpace($ResourceName))
    {
        return $resourceNameToApiUriAreaName[$ResourceName]
    }

    return $resourceNameToApiUriAreaName.Values | Select-Object -Unique
}
