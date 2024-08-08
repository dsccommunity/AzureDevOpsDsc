Describe "Get-AzDevOpsApiWaitTimeoutMs" {
    It "Should return 300000 milliseconds" {
        $result = Get-AzDevOpsApiWaitTimeoutMs
        $result | Should -Be 300000
    }
}

