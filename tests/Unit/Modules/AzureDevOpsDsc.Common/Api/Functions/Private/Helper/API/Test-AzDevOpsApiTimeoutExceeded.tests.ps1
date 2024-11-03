$currentFile = $MyInvocation.MyCommand.Path

Describe "Test-AzDevOpsApiTimeoutExceeded" {

    BeforeAll {
        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath "Test-AzDevOpsApiTimeoutExceeded.tests.ps1"
        }

        # Load the functions to test
        $files = Get-FunctionItem (Find-MockedFunctions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }
    }

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
        {Test-AzDevOpsApiTimeoutExceeded -StartTime $StartTime -EndTime $EndTime -TimeoutMs $TimeoutMs} | Should -Not -Throw
    }

    It "Should return false if duration equals TimeoutMs" {
        $StartTime = [datetime]::Now
        $EndTime = $StartTime.AddMilliseconds(1000)
        $TimeoutMs = 1000
        $result = Test-AzDevOpsApiTimeoutExceeded -StartTime $StartTime -EndTime $EndTime -TimeoutMs $TimeoutMs
        $result | Should -Be $false
    }
}
