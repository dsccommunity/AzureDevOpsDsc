<#
    .SYNOPSIS
        Peforms test on the provided 'StartTime' and 'EndTime', and the provided 'TimeoutMs'
        value to indicate if a timeout duration has expired.

        Returns $true if the test is the duration/difference of time (in Milliseconds) between
        the 2 times is greater than the 'TimeOutMs' value (indicates the timeout has been exceeded).

        Returns $false otherwise.

        NOTE: Ensure both 'StartTime' and 'EndTime' use values in the same time zone.

    .PARAMETER StartTime
        The 'StartTime' of when the timeout duration began.

    .PARAMETER EndTime
        The 'EndTime' of when the timeout duration ended (typically the current time).

    .PARAMETER TimeoutMs
        The number of milliseconds set as the timeout to evaluate against.

    .EXAMPLE
        Test-AzDevOpsTimeoutExceeded -StartTime $someStartTime -EndTime $someEndTime -TimeoutMs 1000

        Returns $true if the duration between the value of $someStartTime and $someEndTime is greater than
        1000 milliseconds (1 second).

        Returns $false if it is not.
#>
function Test-AzDevOpsTimeoutExceeded
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [Datetime]
        $StartTime,

        [Parameter(Mandatory = $true)]
        [Datetime]
        $EndTime,

        [Parameter(Mandatory = $true)]
        [Int32]
        $TimeoutMs
    )

    return $($(New-TimeSpan -Start $StartTime -End $EndTime).Milliseconds -gt $TimeoutMs)
}
