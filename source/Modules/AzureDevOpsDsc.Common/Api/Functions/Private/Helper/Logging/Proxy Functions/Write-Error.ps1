<#
.SYNOPSIS
Logs an error message to a specified log file and displays the error message.

.DESCRIPTION
The Write-Error function logs an error message to a specified log file and displays the error message using the original Write-Error cmdlet.
It appends the error message with a timestamp to the log file.

.PARAMETER Message
The error message to be logged and displayed. This parameter is mandatory.

.PARAMETER LogFilePath
The path to the log file where the error message will be appended. The default path is "C:\Temp\error_log.txt".

.EXAMPLE
Write-Error -Message "An unexpected error occurred."

This example logs the error message "An unexpected error occurred." to the default log file and displays the error message.

.EXAMPLE
Write-Error -Message "An unexpected error occurred." -LogFilePath "C:\Logs\custom_error_log.txt"

This example logs the error message "An unexpected error occurred." to the specified log file "C:\Logs\custom_error_log.txt" and displays the error message.

.NOTES
The function uses the original Write-Error cmdlet from the Microsoft.PowerShell.Utility module to display the error message.
#>
Function Write-Error
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter()]
        [string]$LogFilePath = "$($env:AZDO_ERRORLOGGING_FILEPATH)"
    )

    #  Call the original Write-Error cmdlet to display the message
    Microsoft.PowerShell.Utility\Write-Error $Message
    $VerbosePreference = $originalPreference

    # Test if the env:enableVerboseLogging variable is set to true
    if (-not [String]::IsNullOrEmpty($LogFilePath))
    {
        # Append the message to the log file
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Add-Content -Path $LogFilePath -Value "[$timestamp] $Message"
    }

}
