# Save this script as Test-TestAzDevOpsApiTimeoutExceeded.Tests.ps1

# Import the module or script containing the function
. .\Path\To\Your\Script.ps1

Describe "Test-AzDevOpsApiTimeoutExceeded" {

    Context "When testing timeout duration" {

        It "should return $true if the duration is greater than TimeoutMs" {
            $startTime = [datetime]::Now.AddMilliseconds(-2000) # 2 seconds ago
            $endTime = [datetime]::Now
            $timeoutMs = 1000
            $result = Test-AzDevOpsApiTimeoutExceeded -StartTime $startTime -EndTime $endTime -TimeoutMs $timeoutMs
            $result | Should -Be $true
        }

        It "should return $false if the duration is less than TimeoutMs" {
            $startTime = [datetime]::Now.AddMilliseconds(-500) # 0.5 seconds ago
            $endTime = [datetime]::Now
            $timeoutMs = 1000
            $result = Test-AzDevOpsApiTimeoutExceeded -StartTime $startTime -EndTime $endTime -TimeoutMs $timeoutMs
            $result | Should -Be $false
        }

        It "should return $false if the duration is equal to TimeoutMs" {
            $startTime = [datetime]::Now.AddMilliseconds(-1000) # 1 second ago
            $endTime = [datetime]::Now
            $timeoutMs = 1000
            $result = Test-AzDevOpsApiTimeoutExceeded -StartTime $startTime -EndTime $endTime -TimeoutMs $timeoutMs
            $result | Should -Be $false
        }

        It "should throw an error if TimeoutMs is below the minimum range" {
            $startTime = [datetime]::Now.AddMilliseconds(-1000)
            $endTime = [datetime]::Now
            $timeoutMs = 200 # Below the minimum range of 250 ms
            { Test-AzDevOpsApiTimeoutExceeded -StartTime $startTime -EndTime $endTime -TimeoutMs $timeoutMs } | Should -Throw
        }

        It "should throw an error if TimeoutMs is above the maximum range" {
            $startTime = [datetime]::Now.AddMilliseconds(-1000)
            $endTime = [datetime]::Now
            $timeoutMs = 300001 # Above the maximum range of 300000 ms
            { Test-AzDevOpsApiTimeoutExceeded -StartTime $startTime -EndTime $endTime -TimeoutMs $timeoutMs } | Should -Throw
        }
    }
}
