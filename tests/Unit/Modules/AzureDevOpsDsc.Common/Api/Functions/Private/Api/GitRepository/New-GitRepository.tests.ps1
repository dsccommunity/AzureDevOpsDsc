
Describe 'New-GitRepository Tests' {
    Mock -ModuleName mymodule -FunctionName Invoke-AzDevOpsApiRestMethod

    BeforeAll {
        Import-Module .\path\to\mymodule.psm1 -Force
    }

    BeforeEach {
        Mock Clear-AllMocks
        Set-StrictMode -Version Latest
    }

    Context 'When creating a repository successfully' {
        It 'should invoke the REST method with correct parameters' {
            $mockApiUri = "https://dev.azure.com/org"
            $mockProject = [PSCustomObject]@{ name = 'TestProject'; id = '12345' }
            $mockRepoName = "TestRepo"
            $mockApiVersion = "5.0"

            Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
                [PSCustomObject]@{ name = $mockRepoName }
            } -Verifiable -ParameterFilter { $Body -match "TestRepo" }

            $result = New-GitRepository -ApiUri $mockApiUri -Project $mockProject -RepositoryName $mockRepoName -ApiVersion $mockApiVersion

            Assert-MockCalled Invoke-AzDevOpsApiRestMethod -Exactly 1
            $result.name | Should -Be $mockRepoName
        }
    }

    Context 'When failing to create a repository' {
        It 'should throw an error and write an error message' {
            $mockApiUri = "https://dev.azure.com/org"
            $mockProject = [PSCustomObject]@{ name = 'TestProject'; id = '12345' }
            $mockRepoName = "TestRepo"
            $mockApiVersion = "5.0"

            Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
                throw "API failure"
            } -Verifiable -ParameterFilter { $Body -match "TestRepo" }

            { New-GitRepository -ApiUri $mockApiUri -Project $mockProject -RepositoryName $mockRepoName -ApiVersion $mockApiVersion } | Should -Throw -ErrorId "Write-Error"

            Assert-MockCalled Invoke-AzDevOpsApiRestMethod -Exactly 1
        }
    }
}

