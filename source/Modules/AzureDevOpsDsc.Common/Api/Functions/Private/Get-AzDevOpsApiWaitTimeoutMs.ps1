<#
    .SYNOPSIS
        Returns the number of Milliseconds that will be waited for calls to
        the Azure DevOps API to timeout (during a 'Wait' operation).

    .EXAMPLE
        Get-AzDevOpsApiWaitTimeoutMs

        Returns the number of Milliseconds that will be waited for calls to
        the Azure DevOps API to timeout (during a 'Wait' operation).
#>
function Get-AzDevOpsApiWaitTimeoutMs
{
    [CmdletBinding()]
    [OutputType([Int32])]
    param ()

    return 10000
}
