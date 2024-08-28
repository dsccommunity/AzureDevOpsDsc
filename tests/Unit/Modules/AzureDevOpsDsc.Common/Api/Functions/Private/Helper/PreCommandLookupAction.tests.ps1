# Not implemented
Describe "PreCommandLookupAction" -skip {
    BeforeAll {
        $global:ExecutionContext = [pscustomobject]@{
            InvokeCommand = [pscustomobject]@{
                PreCommandLookupAction = $null
            }
        }
    }

    It "Should throw if Add-AuthenticationHTTPHeader is called outside of Invoke-AzDevOpsApiRestMethod" {
        $customCommand = [pscustomobject]@{ Name = "SomeOtherFunction" }
        $global:MyInvocation = [pscustomobject]@{ MyCommand = $customCommand }

        {
            & $global:ExecutionContext.InvokeCommand.PreCommandLookupAction.Invoke("Add-AuthenticationHTTPHeader", $null)
        } | Should -Throw "The function 'Add-AuthenticationHTTPHeader' can only be called inside of 'Invoke-AzDevOpsApiRestMethod' function."
    }

    It "Should not throw if Add-AuthenticationHTTPHeader is called inside of Invoke-AzDevOpsApiRestMethod" {
        $customCommand = [pscustomobject]@{ Name = "Invoke-AzDevOpsApiRestMethod" }
        $global:MyInvocation = [pscustomobject]@{ MyCommand = $customCommand }

        {
            & $global:ExecutionContext.InvokeCommand.PreCommandLookupAction.Invoke("Add-AuthenticationHTTPHeader", $null)
        } | Should -Not -Throw
    }

    It "Should throw if Export- command is used within Invoke-AzDevOpsApiRestMethod function" {
        $customCommand = [pscustomobject]@{ Name = "Invoke-AzDevOpsApiRestMethod" }
        $global:MyInvocation = [pscustomobject]@{ MyCommand = $customCommand }

        {
            & $global:ExecutionContext.InvokeCommand.PreCommandLookupAction.Invoke("Export-SomeData", $null)
        } | Should -Throw "The command 'Export-SomeData' is not allowed to be used within 'Invoke-AzDevOpsApiRestMethod' function."
    }

    It "Should throw if System.Runtime.InteropServices.Marshal is used outside of AuthenticationToken class" {
        $customCommand = [pscustomobject]@{ Name = "SomeOtherClass" }
        $global:MyInvocation = [pscustomobject]@{ MyCommand = $customCommand }

        {
            & $global:ExecutionContext.InvokeCommand.PreCommandLookupAction.Invoke("System.Runtime.InteropServices.Marshal", $null)
        } | Should -Throw "The command 'System.Runtime.InteropServices.Marshal' is not allowed to be used outside of 'AuthenticationToken' class."
    }

    It "Should not throw if System.Runtime.InteropServices.Marshal is used inside AuthenticationToken class" {
        $customCommand = [pscustomobject]@{ Name = "AuthenticationToken" }
        $global:MyInvocation = [pscustomobject]@{ MyCommand = $customCommand }

        {
            & $global:ExecutionContext.InvokeCommand.PreCommandLookupAction.Invoke("System.Runtime.InteropServices.Marshal", $null)
        } | Should -Not -Throw
    }
}

