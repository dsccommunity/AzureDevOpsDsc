<#
.SYNOPSIS
Writes a verbose message to the console and optionally logs it to a file.

.DESCRIPTION
The Write-Verbose function writes a verbose message to the console using the built-in Write-Verbose cmdlet.
specified by the LogFilePath parameter.

.PARAMETER Message
The verbose message to be written to the console and optionally logged to a file.

.PARAMETER LogFilePath
The path to the log file where the verbose message will be appended. If not specified, the value of the

.EXAMPLE
Write-Verbose -Message "This is a verbose message."

This command writes the message "This is a verbose message." to the console and, if the environment variable

.NOTES
The function uses the built-in Write-Verbose cmdlet to write messages to the console. It also checks if the
#>
Function Write-Verbose
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter()]
        [string]$LogFilePath = "$($env:AZDO_VERBOSELOGGING_FILEPATH)"
    )

    # Call the original Write-Verbose cmdlet to display the message if verbose preference is enabled
    Microsoft.PowerShell.Utility\Write-Verbose $Message

    # Test if the env:enableVerboseLogging variable is set to true
    if ($null -ne $LogFilePath)
    {
        # Append the message to the log file
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Add-Content -Path $LogFilePath -Value "[$timestamp] $Message"
    }

}
