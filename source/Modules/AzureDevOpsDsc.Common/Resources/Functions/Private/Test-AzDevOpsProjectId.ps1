<#
    .SYNOPSIS
        Peforms test on a provided 'ProjectId' to provide a boolean ($true or $false)
        return value. Returns $true if the test is successful.

        NOTE: Use of the '-IsValid' switch is required.

    .PARAMETER ProjectId
        The 'ProjectId' to be tested/validated.

    .PARAMETER IsValid
        Use of this switch will validate the format of the 'ProjectId'
        rather than the existence/presence of it.

        Failure to use this switch will throw an exception.

    .EXAMPLE
        Test-AzDevOpsProjectId -ProjectId 'YourProjectIdHere' -IsValid

        Returns $true if the 'ProjectId' provided is of a valid format.
        Returns $false if it is not.
#>
function Test-AzDevOpsProjectId
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ProjectId,

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

    if (!(Test-AzDevOpsApiResourceId -ResourceId $ProjectId -IsValid:$IsValid))
    {
        return $false
    }

    return $true
}
