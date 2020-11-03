<#
    .SYNOPSIS
        Returns an array of all the supported, Azure DevOps API, versions that can used/managed
        within this module.

    .EXAMPLE
        Get-AzDevOpsApiVersion

        Returns all the names of the objects that can be used/managed in the Azure DevOps API.
#>
function Get-AzDevOpsApiVersion
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Default
    )

    [string]$defaultApiVersion = '6.0'

    [string[]]$apiVersions = @(

        #'4.0', # Not supported
        #'5.0', # Not supported
        #'5.1', # Not supported
        '6.0'
        #'6.1', # Not supported

    )

    if ($Default)
    {
        $apiVersions = $apiVersions |
            Where-Object { $_ -eq $defaultApiVersion}
    }

    return $apiVersions
}
