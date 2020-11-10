<#
    .SYNOPSIS
        Peforms test on a provided 'Personal Access Token' (PAT) to provide a
        boolean ($true or $false) return value. Returns $true if the test is successful.

        NOTE: Use of the '-IsValid' switch is required.

    .PARAMETER Pat
        The 'Personal Access Token' (PAT) to be tested/validated.

    .PARAMETER IsValid
        Use of this switch will validate the format of the 'Personal Access Token' (PAT)
        rather than the existence/presence of the PAT itself.

        Failure to use this switch will throw an exception.

    .EXAMPLE
        Test-AzDevOpsPat -Pat 'YourPatHere' -IsValid

        Returns $true if the 'Personal Access Token' (PAT) provided is of a valid format.
        Returns $false if it is not.
#>
function Test-AzDevOpsPat
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Pat,

        [Parameter(Mandatory = $true)]
        [ValidateSet($true)]
        [System.Management.Automation.SwitchParameter]
        $IsValid
    )

    if (!$IsValid)
    {
        $errorMessage = $script:localizedData.MandatoryIsValidSwitchNotUsed -f $MyInvocation.MyCommand
        New-InvalidOperationException -Message $errorMessage
    }

    if ([System.String]::IsNullOrWhiteSpace($Pat) -or
        $Pat.Length -ne 52) # Note: 52 is the current/expected length of PAT
    {
        return $false
    }

    return $true
}
