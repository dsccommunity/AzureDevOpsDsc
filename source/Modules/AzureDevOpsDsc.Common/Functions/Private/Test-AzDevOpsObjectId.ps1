<#
    .SYNOPSIS
        Peforms test on a provided 'ObjectId' to provide a boolean ($true or $false)
        return value. Returns $true if the test is successful.

        NOTE: Use of the '-IsValid' switch is required.

    .PARAMETER ObjectId
        The 'ObjectId' to be tested/validated.

    .PARAMETER IsValid
        Use of this switch will validate the format of the 'ObjectId'
        rather than the existence/presence of it.

        Failure to use this switch will throw an exception.

    .EXAMPLE
        Test-AzDevOpsObjectId -ObjectId 'YourObjectIdHere' -IsValid

        Returns $true if the 'ObjectId' provided is of a valid format.
        Returns $false if it is not.
#>
function Test-AzDevOpsObjectId
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ObjectId,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.SwitchParameter]
        $IsValid
    )

    if (!$IsValid)
    {
        $errorMessage = $script:localizedData.MandatoryIsValidSwitchNotUsed -f $MyInvocation.MyCommand
        New-InvalidOperationException -Message $errorMessage
    }


    if (![guid]::TryParse($ObjectId, $([ref][guid]::Empty)))
    {
        return $false
    }


    return $true
}
