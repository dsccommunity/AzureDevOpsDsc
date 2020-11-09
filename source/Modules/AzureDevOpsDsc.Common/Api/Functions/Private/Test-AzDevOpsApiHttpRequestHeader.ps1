<#
    .SYNOPSIS
        Peforms test on a provided 'HttpRequestHeader' to provide a boolean ($true or $false)
        return value. Returns $true if the test is successful.

        NOTE: Use of the '-IsValid' switch is required.

    .PARAMETER HttpRequestHeader
        The 'HttpRequestHeader' to be tested/validated.

    .PARAMETER IsValid
        Use of this switch will validate the format of the 'HttpRequestHeader'
        rather than the existence/presence of it.

        Failure to use this switch will throw an exception.

    .EXAMPLE
        Test-AzDevOpsApiHttpRequestHeader -HttpRequestHeader 'YourHttpRequestHeaderHere' -IsValid

        Returns $true if the 'HttpRequestHeader' provided is of a valid format.
        Returns $false if it is not.
#>
function Test-AzDevOpsApiHttpRequestHeader
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [Hashtable]
        $HttpRequestHeader,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.SwitchParameter]
        $IsValid
    )

    if (!$IsValid)
    {
        $errorMessage = $script:localizedData.MandatoryIsValidSwitchNotUsed -f $MyInvocation.MyCommand
        New-InvalidOperationException -Message $errorMessage
    }


    if ($null -eq $HttpRequestHeader -or
        $null -eq $HttpRequestHeader.Authorization -or
        $HttpRequestHeader.Authorization -inotlike 'Basic *')
    {
        return $false
    }

    return $true
}
