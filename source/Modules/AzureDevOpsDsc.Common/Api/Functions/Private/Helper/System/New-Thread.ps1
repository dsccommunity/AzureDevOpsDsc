<#
.SYNOPSIS
Creates and starts a new thread to run the specified script block.

.DESCRIPTION
The New-Thread function creates a new thread using the provided script block and starts it.
This can be useful for running tasks concurrently.

.PARAMETER ScriptBlock
The script block to be executed in the new thread. This parameter is mandatory.

.EXAMPLE
$scriptBlock = {
    # Your code here
}
$thread = New-Thread -ScriptBlock $scriptBlock

.NOTES
Author: Your Name
Date: YYYY-MM-DD
#>
Function New-Thread
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
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
