<#
    .SYNOPSIS
        Returns an array of all the Azure DevOps API, URI-specific, 'Resource' names that can used/managed.

    .EXAMPLE
        Get-AzDevOpsApiUriResourceName

        Returns all the names of the URI-specific, resource names that can be used/managed in the Azure DevOps API.

    .EXAMPLE
        Get-AzDevOpsApiUriResourceName -ResourceName 'YourResourceNameHere'

        Returns the URI-specific, resource name that can be used/managed in the Azure DevOps API for the given
        'ResourceName' (e.g. 'Project' or 'Operation')
#>
function Get-AzDevOpsApiUriResourceName
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter()]
        [ValidateScript({ Test-AzDevOpsApiResourceName -ResourceName $_ -IsValid })]
        [System.String]
        $ResourceName
    )

    [hashtable]$apiResourceNameToApiUriResourceName = @{
        Operation = 'operations'
        Project = 'projects'
    }

    if (![string]::IsNullOrWhiteSpace($ResourceName))
    {
        return $apiResourceNameToApiUriResourceName[$ResourceName]
    }

    return [System.String[]]$($apiResourceNameToApiUriResourceName.Values)
}
