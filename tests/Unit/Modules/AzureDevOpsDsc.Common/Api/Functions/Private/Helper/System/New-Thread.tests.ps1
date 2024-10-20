Describe 'New-Thread' -skip {
    BeforeAll {
        function New-Thread {
            [CmdletBinding()]
            param (
                [Parameter(Mandatory)]
                [ScriptBlock]$ScriptBlock
            )

            Write-Verbose "[New-Thread] Started."
            $thread = [System.Threading.Thread]::new($ScriptBlock)
            $thread.Start()
            Write-Verbose "[New-Thread] Completed."
            return $thread
        }
    }

    It 'Throws an error when ScriptBlock is not provided' {
        { New-Thread } | Should -Throw
    }

    It 'Creates and starts a new thread' {
        $scriptBlock = { Start-Sleep -Seconds 3 }
        $thread = New-Thread -ScriptBlock $scriptBlock
        $thread | Should -BeOfType 'System.Threading.Thread'
        $thread.IsAlive | Should -Be $true
    }

    It 'Thread runs the provided ScriptBlock' {
        $hasRun = $false
        $scriptBlock = { $script:hasRun = $true }
        $thread = New-Thread -ScriptBlock $scriptBlock
        $thread.Join()
        $hasRun | Should -Be $true
    }

    It 'Verbose output is produced' {
        $verboseOutput = {
            $scriptBlock = { Start-Sleep -Seconds 1 }
            New-Thread -ScriptBlock $scriptBlock -Verbose
        } | Out-String
        $verboseOutput | Should -Contain '[New-Thread] Started.'
        $verboseOutput | Should -Contain '[New-Thread] Completed.'
    }
}

