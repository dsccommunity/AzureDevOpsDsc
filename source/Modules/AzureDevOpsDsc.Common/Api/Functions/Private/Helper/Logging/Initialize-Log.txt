Function Initialize-Log {
    [CmdletBinding()]
    param (
        # The directory where the log files will be stored.
        [Parameter()]
        [string]$LogDirectory=$ENV:AZDODSC_CACHE_DIRECTORY
    )

    Write-Verbose "[Initialize-Log] Started."

    # Define the log path
    $Global:AZDO_VerboseLog         = [System.Collections.Generic.List[String]]::new()
    $Global:AZDO_WarningLog         = [System.Collections.Generic.List[String]]::new()

    $Global:AZDO_LogSettings = @{
        VerboseLogFilePath = Join-Path -Path $LogDirectory -ChildPath "Verbose.log"
        WarningLogFilePath = Join-Path -Path $LogDirectory -ChildPath "Warning.log"
        VerboseCount       = 0
        WarningCount       = 0
        LogCountLimit      = 100
    }

    # Ensure the log directory exists
    if (-not (Test-Path -Path $LogDirectory)) {
        Write-Verbose "[Initialize-Log] Log directory does not exist. Creating directory."
        New-Item -ItemType Directory -Path $LogDirectory -Force | Out-Null
    }

    # Initialize the log files
    Write-Verbose "[Initialize-Log] Log files initialized at: $LogDirectory"
}
