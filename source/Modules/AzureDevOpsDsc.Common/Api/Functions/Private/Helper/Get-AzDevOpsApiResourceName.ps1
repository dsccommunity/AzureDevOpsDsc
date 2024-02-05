<#
    .SYNOPSIS
        Returns an array of all the Azure DevOps API, 'Resource' names that can used/managed
        in the Azure DevOps API (and supported by the 'AzureDevOpsDsc' module).

    .EXAMPLE
        Get-AzDevOpsApiResourceName

        Returns all the names of the resources that can be used/managed in the Azure DevOps API.
#>
function Get-AzDevOpsApiResourceName
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param ()

    return [System.String[]]@(
        'Operation',
        'Project'
    )
}
