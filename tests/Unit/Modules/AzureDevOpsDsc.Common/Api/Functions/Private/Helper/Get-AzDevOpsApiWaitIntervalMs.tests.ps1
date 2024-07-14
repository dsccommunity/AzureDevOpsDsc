powershell
Describe "Get-AzDevOpsApiWaitIntervalMs" {
    It "Should return an integer" {
        $result = Get-AzDevOpsApiWaitIntervalMs
        $result | Should -BeOfType [Int32]
    }

    It "Should return 500" {
        $result = Get-AzDevOpsApiWaitIntervalMs
        $result | Should -Be 500
    }
}

