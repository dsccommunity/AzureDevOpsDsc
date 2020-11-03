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
    [OutputType([System.Object[]])]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateScript({ Test-AzDevOpsApiResourceName -ResourceName $_ -IsValid })]
        [System.String]
        $ResourceName
    )

    [hashtable]$resourceNameToApiUriResourceName = @{
        Operation = 'operations'
        Project = 'projects'
    }

    if (![string]::IsNullOrWhiteSpace($ResourceName))
    {
        return $resourceNameToApiUriResourceName[$ResourceName]
    }

    return $resourceNameToApiUriResourceName.Values
}
