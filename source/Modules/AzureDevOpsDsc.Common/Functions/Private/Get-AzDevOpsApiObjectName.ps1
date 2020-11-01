<#
    .SYNOPSIS
        Returns an array of all the Azure DevOps API, 'Object' names that can used/managed.

    .EXAMPLE
        Get-AzDevOpsApiObjectName

        Returns all the names of the objects that can be used/managed in the Azure DevOps API.
#>
function Get-AzDevOpsApiObjectName
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param ()

    [string[]]$objectNames = @(
        'Operation',
        'Project'
    )

    return $objectNames
}
