<#
    .SYNOPSIS
        Returns an array of all the supported, Azure DevOps API, versions that can used/managed
        within this module.

    .EXAMPLE
        Get-AzDevOpsApiVersion

        Returns all the names of the resources that can be used/managed in the Azure DevOps API.
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

    [string]$defaultApiVersion = '7.0-preview.1'

    [string[]]$apiVersions = @(

        #'4.0', # Not supported
        #'5.0', # Not supported
        #'5.1', # Not supported
        '6.0',
        '7.0-preview.1',
        '7.1-preview.1',
        '7.2-preview.4'

    )

    if ($Default)
    {
        $apiVersions = $apiVersions |
            Where-Object { $_ -eq $defaultApiVersion}
    }

    return $apiVersions
}
