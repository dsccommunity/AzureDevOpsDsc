Function New-Thread {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ScriptBlock]$ScriptBlock
    )

    #
    # Logging
    Write-Verbose "[New-Thread] Started."

    #
    # Create a new thread
    $thread = [System.Threading.Thread]::new($ScriptBlock)
    $thread.Start()

    #
    # Return the thread
    Write-Verbose "[New-Thread] Completed."
    return $thread
}
