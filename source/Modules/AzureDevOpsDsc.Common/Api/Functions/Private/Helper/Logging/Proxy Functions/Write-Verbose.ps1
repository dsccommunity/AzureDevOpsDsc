Function Write-Verbose {
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
    if ($null -ne $env:AZDO_VERBOSELOGGING_FILEPATH) {
        # Append the message to the log file
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Add-Content -Path $LogFilePath -Value "[$timestamp] $Message"
    }

}
