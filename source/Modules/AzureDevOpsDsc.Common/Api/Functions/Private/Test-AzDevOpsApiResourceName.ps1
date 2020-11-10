<#
    .SYNOPSIS
        Peforms test on a provided 'ResourceName' to provide a boolean ($true or $false)
        return value. Returns $true if the test is successful.

        NOTE: Use of the '-IsValid' switch is required.

    .PARAMETER ResourceName
        The 'ResourceName' to be tested/validated.

    .PARAMETER IsValid
        Use of this switch will validate the format of the 'ResourceName'
        rather than the existence/presence of it.

        Failure to use this switch will throw an exception.

    .EXAMPLE
        Test-AzDevOpsApiResourceName -ResourceName 'YourResourceNameHere' -IsValid

        Returns $true if the 'ResourceName' provided is of a valid format.
        Returns $false if it is not.
#>
function Test-AzDevOpsApiResourceName
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceName,

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


    if (!($(Get-AzDevOpsApiResourceName).Contains($ResourceName)))
    {
        return $false
    }


    return $true
}
