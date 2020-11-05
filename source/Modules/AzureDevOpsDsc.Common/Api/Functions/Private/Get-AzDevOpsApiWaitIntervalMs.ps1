<#
    .SYNOPSIS
        Returns the number of Milliseconds that will be waited for between calls
        to the Azure DevOps API.

    .EXAMPLE
        Get-AzDevOpsApiWaitIntervalMs

        Returns the number of Milliseconds that will be waited for between calls
        to the Azure DevOps API.
#>
function Get-AzDevOpsApiWaitIntervalMs
{
    [CmdletBinding()]
    [OutputType([int])]
    param ()

    return 500
}
