Describe 'Wait-AzDevOpsApiResource' {
    Mock -ModuleName 'YourModuleNameHere' -CommandName 'Test-AzDevOpsApiUri' -MockWith { return $true }
    Mock -ModuleName 'YourModuleNameHere' -CommandName 'Test-AzDevOpsApiVersion' -MockWith { return $true }
    Mock -ModuleName 'YourModuleNameHere' -CommandName 'Test-AzDevOpsPat' -MockWith { return $true }
    Mock -ModuleName 'YourModuleNameHere' -CommandName 'Test-AzDevOpsApiResourceName' -MockWith { return $true }
    Mock -ModuleName 'YourModuleNameHere' -CommandName 'Test-AzDevOpsApiResourceId' -MockWith { return $true }
    Mock -ModuleName 'YourModuleNameHere' -CommandName 'Get-AzDevOpsApiVersion' -MockWith { return '6.0' }
    Mock -ModuleName 'YourModuleNameHere' -CommandName 'Get-AzDevOpsApiWaitIntervalMs' -MockWith { return 1000 }
    Mock -ModuleName 'YourModuleNameHere' -CommandName 'Get-AzDevOpsApiWaitTimeoutMs' -MockWith { return 30000 }
    Mock -ModuleName 'YourModuleNameHere' -CommandName 'Test-AzDevOpsApiResource' -MockWith { return $false }
    Mock -ModuleName 'YourModuleNameHere' -CommandName 'Test-AzDevOpsApiTimeoutExceeded' -MockWith { return $false }
    Mock -ModuleName 'YourModuleNameHere' -CommandName 'New-InvalidOperationException' -MockWith { Throw "Operation Timeout" }

    Context 'When waiting for resource to be present' {
        It 'Waits for the resource to be present' {
            $script:localizedData = @{
                AzDevOpsApiResourceWaitTimeoutExceeded = 'Timeout exceeded waiting for {0} resource {1} with ID {2} after {3} milliseconds.'
            }
            $params = @{
                ApiUri            = 'https://dev.azure.com/example/_apis/'
                Pat               = 'dummyPAT'
                ResourceName      = 'Project'
                ResourceId        = 'dummyResourceId'
                IsPresent         = $true
                WaitIntervalMilliseconds = 1000
                WaitTimeoutMilliseconds  = 5000
            }

            { Wait-AzDevOpsApiResource @params } | Should -Not -Throw
        }
    }

    Context 'When waiting for resource to be absent' {
        It 'Waits for the resource to be absent' {
            Mock -ModuleName 'YourModuleNameHere' -CommandName 'Test-AzDevOpsApiResource' -MockWith { return $true }
            $script:localizedData = @{
                AzDevOpsApiResourceWaitTimeoutExceeded = 'Timeout exceeded waiting for {0} resource {1} with ID {2} after {3} milliseconds.'
            }
            $params = @{
                ApiUri            = 'https://dev.azure.com/example/_apis/'
                Pat               = 'dummyPAT'
                ResourceName      = 'Project'
                ResourceId        = 'dummyResourceId'
                IsAbsent          = $true
                WaitIntervalMilliseconds = 1000
                WaitTimeoutMilliseconds  = 5000
            }

            { Wait-AzDevOpsApiResource @params } | Should -Not -Throw
        }
    }

    Context 'When both IsPresent and IsAbsent are missing' {
        It 'Throws an error' {
            $params = @{
                ApiUri            = 'https://dev.azure.com/example/_apis/'
                Pat               = 'dummyPAT'
                ResourceName      = 'Project'
                ResourceId        = 'dummyResourceId'
            }

            { Wait-AzDevOpsApiResource @params } | Should -Throw
        }
    }
}


