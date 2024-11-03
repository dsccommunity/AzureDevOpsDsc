$currentFile = $MyInvocation.MyCommand.Path

Describe 'Get-DevOpsSecurityDescriptor Tests' -Tags "Unit", "API" {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Get-DevOpsSecurityDescriptor.tests.ps1'
        }

        # Load the functions to test
        $files = Get-FunctionItem (Find-MockedFunctions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
            return @{ value = 'MockedResponse' }
        }

        $ProjectId = 'TestProjectId'
        $Organization = 'TestOrganization'
        $ApiVersion = '6.0'

    }

    It 'should retrieve the security descriptor for a project' {
        $response = Get-DevOpsSecurityDescriptor -ProjectId $ProjectId -Organization $Organization -ApiVersion $ApiVersion
        $response | Should -Be 'MockedResponse'
    }

    It 'should call Invoke-AzDevOpsApiRestMethod once' {
        Get-DevOpsSecurityDescriptor -ProjectId $ProjectId -Organization $Organization -ApiVersion $ApiVersion
        Assert-MockCalled -CommandName 'Invoke-AzDevOpsApiRestMethod' -Exactly 1 -Scope It
    }

    It 'should call Invoke-AzDevOpsApiRestMethod with correct parameters' {
        Get-DevOpsSecurityDescriptor -ProjectId $ProjectId -Organization $Organization -ApiVersion $ApiVersion
        Assert-MockCalled -CommandName 'Invoke-AzDevOpsApiRestMethod' -Exactly 1 -Scope It -ParameterFilter {
            $ApiUri -eq "https://vssps.dev.azure.com/TestOrganization/_apis/graph/descriptors/TestProjectId?api-version=6.0" -and
            $Method -eq 'GET'
        }
    }

    It 'should handle errors gracefully' {
        Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith { throw "API Error" }
        Mock -CommandName Write-Error -Verifiable

        { Get-DevOpsSecurityDescriptor -ProjectId $ProjectId -Organization $Organization -ApiVersion $ApiVersion } | Should -Not -Throw
    }
}
