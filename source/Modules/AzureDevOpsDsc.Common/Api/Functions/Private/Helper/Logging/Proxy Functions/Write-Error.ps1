Function Write-Error {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter()]
        [string]$LogFilePath = "C:\Temp\error_log.txt"
    )

    #  Call the original Write-Error cmdlet to display the message
    Microsoft.PowerShell.Utility\Write-Error $Message
    $VerbosePreference = $originalPreference

    # Append the message to the log file
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFilePath -Value "[$timestamp] $Message"

}
