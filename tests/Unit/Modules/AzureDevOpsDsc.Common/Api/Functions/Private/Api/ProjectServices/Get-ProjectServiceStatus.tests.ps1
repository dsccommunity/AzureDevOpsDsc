
Describe 'Get-ProjectServiceStatus' {
    Mock -ModuleName 'Az.DevOps' Get-AzDevOpsApiVersion { '6.0-preview.1' }
    Mock -ModuleName 'Az.DevOps' Invoke-AzDevOpsApiRestMethod {
        [pscustomobject]@{
            state = 'enabled'
        }
    }

    Context 'When all parameters are valid' {
        It 'Should return the state of the service as enabled' {
            $organization = 'TestOrg'
            $projectId = 'TestProjectId'
            $serviceName = 'TestServiceName'

            $result = Get-ProjectServiceStatus -Organization $organization -ProjectId $projectId -ServiceName $serviceName

            $result.state | Should -Be 'enabled'
        }

        It 'Should call Invoke-AzDevOpsApiRestMethod with correct parameters' {
            $organization = 'TestOrg'
            $projectId = 'TestProjectId'
            $serviceName = 'TestServiceName'

            $result = Get-ProjectServiceStatus -Organization $organization -ProjectId $projectId -ServiceName $serviceName

            Assert-MockCalled -ModuleName 'Az.DevOps' Invoke-AzDevOpsApiRestMethod -Exactly -Exactly 1
        }
    }

    Context 'When service state is undefined' {
        Mock -ModuleName 'Az.DevOps' Invoke-AzDevOpsApiRestMethod {
            [pscustomobject]@{
                state = 'undefined'
            }
        }

        It 'Should treat undefined state as enabled' {
            $organization = 'TestOrg'
            $projectId = 'TestProjectId'
            $serviceName = 'TestServiceName'

            $result = Get-ProjectServiceStatus -Organization $organization -ProjectId $projectId -ServiceName $serviceName

            $result.state | Should -Be 'enabled'
        }
    }

    Context 'When an error occurs during API call' {
        Mock -ModuleName 'Az.DevOps' Invoke-AzDevOpsApiRestMethod { throw "API Error" }

        It 'Should write an error message' {
            $organization = 'TestOrg'
            $projectId = 'TestProjectId'
            $serviceName = 'TestServiceName'

            { Get-ProjectServiceStatus -Organization $organization -ProjectId $projectId -ServiceName $serviceName } | Should -Throw
        }
    }
}

