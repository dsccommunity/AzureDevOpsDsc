powershell
Describe 'PreCommandLookupAction Tests' {
    BeforeAll {
        $global:ExecutionContext.InvokeCommand.PreCommandLookupAction = {
            param($command, $commandScriptBlock)

            if ($command -eq 'Add-AuthenticationHTTPHeader' -and $MyInvocation.MyCommand.Name -ne 'Invoke-AzDevOpsApiRestMethod') {
                throw "The function 'Add-AuthenticationHTTPHeader' can only be called inside of 'Invoke-AzDevOpsApiRestMethod' function."
            }

            if ($command -match 'Export-') {
                throw "The command '$command' is not allowed to be used within 'Invoke-AzDevOpsApiRestMethod' function."
            }

            if ($command -match 'System.Runtime.InteropServices.Marshal' -and $MyInvocation.MyCommand.Name -ne 'AuthenticationToken') {
                throw "The command '$command' is not allowed to be used outside of 'AuthenticationToken' class."
            }
        }
    }

    It 'Should throw error when Add-AuthenticationHTTPHeader is called outside of Invoke-AzDevOpsApiRestMethod' {
        {$ExecutionContext.InvokeCommand.InvokeScript([scriptblock]::Create('Add-AuthenticationHTTPHeader'))} | Should -Throw 'The function ''Add-AuthenticationHTTPHeader'' can only be called inside of ''Invoke-AzDevOpsApiRestMethod'' function.'
    }

    It 'Should not throw error when Add-AuthenticationHTTPHeader is called inside of Invoke-AzDevOpsApiRestMethod' {
        {$ExecutionContext.InvokeCommand.InvokeScript([scriptblock]::Create('function Invoke-AzDevOpsApiRestMethod { Add-AuthenticationHTTPHeader }; Invoke-AzDevOpsApiRestMethod'))} | Should -Not -Throw
    }

    It 'Should throw error when any Export function is used within Invoke-AzDevOpsApiRestMethod' {
        {$ExecutionContext.InvokeCommand.InvokeScript([scriptblock]::Create('function Invoke-AzDevOpsApiRestMethod { Export-FakeFunction }; Invoke-AzDevOpsApiRestMethod'))} | Should -Throw "The command 'Export-FakeFunction' is not allowed to be used within 'Invoke-AzDevOpsApiRestMethod' function."
    }

    It 'Should not throw error when Export function is called outside of Invoke-AzDevOpsApiRestMethod' {
        {$ExecutionContext.InvokeCommand.InvokeScript([scriptblock]::Create('Export-FakeFunction'))} | Should -Not -Throw
    }

    It 'Should throw error when [System.Runtime.InteropServices.Marshal] is used outside of AuthenticationToken class' {
        {$ExecutionContext.InvokeCommand.InvokeScript([scriptblock]::Create('[System.Runtime.InteropServices.Marshal]::AllocHGlobal(10)'))} | Should -Throw "The command '[System.Runtime.InteropServices.Marshal]' is not allowed to be used outside of 'AuthenticationToken' class."
    }

    It 'Should not throw error when [System.Runtime.InteropServices.Marshal] is used inside of AuthenticationToken class' {
        {$ExecutionContext.InvokeCommand.InvokeScript([scriptblock]::Create('class AuthenticationToken { [void] TestMethod() { [System.Runtime.InteropServices.Marshal]::AllocHGlobal(10) } }; [AuthenticationToken]::new().TestMethod()'))} | Should -Not -Throw
    }
}

