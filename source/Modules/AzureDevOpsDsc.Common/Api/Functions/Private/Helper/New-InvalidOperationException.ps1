<#
.SYNOPSIS
Creates a new InvalidOperationException error record.

.DESCRIPTION
The New-InvalidOperationException function generates a new ErrorRecord object for an InvalidOperationException with a specified message. Optionally, it can throw the error.

.PARAMETER Message
The message that describes the error. This parameter is mandatory and cannot be null or empty.

.PARAMETER Throw
A switch parameter that, if specified, will throw the generated ErrorRecord instead of returning it.

.OUTPUTS
System.Management.Automation.ErrorRecord

.EXAMPLE
PS> New-InvalidOperationException -Message "An invalid operation occurred."

Creates and returns an ErrorRecord for an InvalidOperationException with the specified message.

.EXAMPLE
PS> New-InvalidOperationException -Message "An invalid operation occurred." -Throw

Creates and throws an ErrorRecord for an InvalidOperationException with the specified message.
#>
using namespace System.Management.Automation

function New-InvalidOperationException
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.ErrorRecord])]
    param (
        [Parameter(
            Position = 0,
            Mandatory
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $Message,

        [Parameter()]
        [switch]
        $Throw
    )
    process
    {
        $ErrorRecord = [ErrorRecord]::new(
            [InvalidOperationException]::new($Message),
            "System.InvalidOperationException",
            [ErrorCategory]::ConnectionError,
            $null
        )

        if ($Throw)
        {
            throw $ErrorRecord
        }

        Write-Output $ErrorRecord

    }
}
