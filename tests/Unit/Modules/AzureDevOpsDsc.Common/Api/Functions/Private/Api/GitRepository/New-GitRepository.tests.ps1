$currentFile = $MyInvocation.MyCommand.Path

Describe 'New-GitRepository Tests' -Tags "Unit", "API" {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'New-GitRepository.tests.ps1'
        }

        # Load the functions to test
        $files = Get-FunctionItem (Find-MockedFunctions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        Mock -CommandName Invoke-AzDevOpsApiRestMethod

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

            Mock -CommandName Write-Error -Verifiable

            { New-GitRepository -ApiUri $mockApiUri -Project $mockProject -RepositoryName $mockRepoName -ApiVersion $mockApiVersion } | Should -Not -Throw

            Assert-MockCalled Invoke-AzDevOpsApiRestMethod -Exactly 1
        }
    }
}

