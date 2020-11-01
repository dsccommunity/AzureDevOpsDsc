<#
    .SYNOPSIS
        Peforms test on a provided 'ObjectName' to provide a boolean ($true or $false)
        return value. Returns $true if the test is successful.

        NOTE: Use of the '-IsValid' switch is required.

    .PARAMETER ObjectName
        The 'ObjectName' to be tested/validated.

    .PARAMETER IsValid
        Use of this switch will validate the format of the 'ObjectName'
        rather than the existence/presence of it.

        Failure to use this switch will throw an exception.

    .EXAMPLE
        Test-AzDevOpsObjectName -ObjectName 'YourObjectNameHere' -IsValid

        Returns $true if the 'ObjectName' provided is of a valid format.
        Returns $false if it is not.
#>
function Test-AzDevOpsObjectName
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ObjectName,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.SwitchParameter]
        $IsValid
    )

    if (!$IsValid)
    {
        $errorMessage = $script:localizedData.MandatoryIsValidSwitchNotUsed -f $MyInvocation.MyCommand
        New-InvalidOperationException -Message $errorMessage
    }


    if (!($(Get-AzDevOpsApiObjectName).Contains($ObjectName)))
    {
        return $false
    }


    return $true
}
