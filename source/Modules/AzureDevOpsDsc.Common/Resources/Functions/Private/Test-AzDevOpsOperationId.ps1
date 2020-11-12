<#
    .SYNOPSIS
        Peforms test on a provided 'OperationId' to provide a boolean ($true or $false)
        return value. Returns $true if the test is successful.

        NOTE: Use of the '-IsValid' switch is required.

    .PARAMETER OperationId
        The 'OperationId' to be tested/validated.

    .PARAMETER IsValid
        Use of this switch will validate the format of the 'OperationId'
        rather than the existence/presence of it.

        Failure to use this switch will throw an exception.

    .EXAMPLE
        Test-AzDevOpsOperationId -OperationId 'YourOperationIdHere' -IsValid

        Returns $true if the 'OperationId' provided is of a valid format.
        Returns $false if it is not.
#>
function Test-AzDevOpsOperationId
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $OperationId,

        [Parameter(Mandatory = $true)]
        [ValidateSet($true)]
        [System.Management.Automation.SwitchParameter]
        $IsValid
    )

    if (!(Test-AzDevOpsApiResourceId -ResourceId $OperationId -IsValid:$IsValid))
    {
        return $false
    }

    return $true
}
