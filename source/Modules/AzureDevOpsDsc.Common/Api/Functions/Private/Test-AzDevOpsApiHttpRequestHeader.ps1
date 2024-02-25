<#
    .SYNOPSIS
        Peforms test on a provided 'HttpRequestHeader' to provide a boolean ($true or $false)
        return value. Returns $true if the test is successful.

        NOTE: Use of the '-IsValid' switch is required.

        PAT Tokens and Managed Identity Tokens are allowed.

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
        [ValidateSet($true)]
        [System.Management.Automation.SwitchParameter]
        $IsValid
    )

    # if Metadata is specifed within the header then it is a Managed Identity Token request
    # and is valid.

    if ($HttpRequestHeader.Metadata)
    {
        return $true
    }

    # Otherwise, if the header is not valid, retrun false

    return !($null -eq $HttpRequestHeader -or
             $null -eq $HttpRequestHeader.Authorization -or
             $HttpRequestHeader.Authorization -match '^(Basic|Bearer):\s.+$')
}
