$currentFile = $MyInvocation.MyCommand.Path

Describe 'Get-ProjectServiceStatus' -Tags "Unit", "API" {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Get-ProjectServiceStatus.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        Mock -CommandName Get-AzDevOpsApiVersion -MockWith {
            return '6.0-preview.1'
        }
        Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
            return [pscustomobject]@{
                state = 'enabled'
            }
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

            Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Exactly -Times 1
        }
    }

    Context 'When service state is undefined' {
        Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
            return [pscustomobject]@{
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

        It 'Should write an error message' {

            Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith { throw "API Error" }
            Mock -CommandName Write-Error -Verifiable

            $organization = 'TestOrg'
            $projectId = 'TestProjectId'
            $serviceName = 'TestServiceName'

            { Get-ProjectServiceStatus -Organization $organization -ProjectId $projectId -ServiceName $serviceName } | Should -Not -Throw
        }
    }
}
