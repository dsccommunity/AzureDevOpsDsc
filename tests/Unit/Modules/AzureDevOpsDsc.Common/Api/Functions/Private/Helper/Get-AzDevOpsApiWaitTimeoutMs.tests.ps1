
Describe "Get-AzDevOpsApiWaitTimeoutMs" {
    It "should return 300000" {
        $result = Get-AzDevOpsApiWaitTimeoutMs
        $result | Should -Be 300000
    }

    It "should return an integer" {
        $result = Get-AzDevOpsApiWaitTimeoutMs
        $result | Should -BeOfType -TypeName 'int'
    }
}

