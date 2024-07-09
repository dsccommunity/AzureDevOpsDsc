Function Flush-Log
{
    [CmdletBinding()]
    param
    ()

    Write-Verbose "[Flush-Log] Started."

    # Write the log messages to the log files
    Write-Verbose "[Flush-Log] Writing log messages to log files."
    $LogFilePaths = @(
        $Global:AZDO_LogSettings.VerboseLogFilePath
        $Global:AZDO_LogSettings.WarningLogFilePath
        $Global:AZDO_LogSettings.ErrorLogFilePath
    )

    $LogMessages = @(
        $Global:AZDO_VerboseLog
        $Global:AZDO_WarningLog
        $Global:AZDO_ErrorLog
    )

    for ($i = 0; $i -lt $LogFilePaths.Count; $i++)
    {
        $LogFilePath = $LogFilePaths[$i]
        $LogMessages = $LogMessages[$i]

        $LogMessages | Out-File -FilePath $LogFilePath -Append

        # Clear the log messages
        $LogMessages.Clear()
        $Global:AZDO_LogSettings."$($LogFilePath.Split('.')[-2])Count" = 0
    }

    Write-Verbose "[Flush-Log] Log messages written to log files."
}
