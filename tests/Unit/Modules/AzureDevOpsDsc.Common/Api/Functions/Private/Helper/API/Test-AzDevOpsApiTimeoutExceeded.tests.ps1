Describe "Test-AzDevOpsApiTimeoutExceeded" {
    It "Should return true if duration exceeds TimeoutMs" {
        $StartTime = [datetime]::Now
        $EndTime = $StartTime.AddMilliseconds(1200)
        $TimeoutMs = 1000
        $result = Test-AzDevOpsApiTimeoutExceeded -StartTime $StartTime -EndTime $EndTime -TimeoutMs $TimeoutMs
        $result | Should -Be $true
    }

    It "Should return false if duration does not exceed TimeoutMs" {
        $StartTime = [datetime]::Now
        $EndTime = $StartTime.AddMilliseconds(800)
        $TimeoutMs = 1000
        $result = Test-AzDevOpsApiTimeoutExceeded -StartTime $StartTime -EndTime $EndTime -TimeoutMs $TimeoutMs
        $result | Should -Be $false
    }

    It "Should validate the TimeoutMs parameter against its range" {
        $StartTime = [datetime]::Now
        $EndTime = $StartTime.AddMilliseconds(3000)
        $TimeoutMs = 200000
        {Test-AzDevOpsApiTimeoutExceeded -StartTime $StartTime -EndTime $EndTime -TimeoutMs $TimeoutMs} | Should -Throw
    }

    It "Should return false if duration equals TimeoutMs" {
        $StartTime = [datetime]::Now
        $EndTime = $StartTime.AddMilliseconds(1000)
        $TimeoutMs = 1000
        $result = Test-AzDevOpsApiTimeoutExceeded -StartTime $StartTime -EndTime $EndTime -TimeoutMs $TimeoutMs
        $result | Should -Be $false
    }
}

