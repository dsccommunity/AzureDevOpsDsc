$currentFile = $MyInvocation.MyCommand.Path

Describe "Get-AzDoGitRepository Tests" {

    AfterAll {
        Remove-Variable -Name DSCAZDO_OrganizationName -Scope Global
    }

    BeforeAll {

        $Global:DSCAZDO_OrganizationName = 'TestOrganization'

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Get-AzDoGitRepository.tests.ps1'
        }

        # Load the functions to test
        $files = Get-FunctionItem (Find-MockedFunctions -TestFilePath $currentFile)

        ForEach ($file in $files) {
            . $file.FullName
        }

        # Load the summary state
        . (Get-ClassFilePath 'DSCGetSummaryState')
        . (Get-ClassFilePath '000.CacheItem')
        . (Get-ClassFilePath 'Ensure')


        Mock -CommandName Get-CacheItem -MockWith {
            return @{ RepositoryName = $repositoryName }
        }

    }

    Context "When repository exists in the live cache" {

        It "should return repository from the live cache with Unchanged status" {
            $projectName = "TestProject"
            $repositoryName = "TestRepository"
            $projectGroupKey = "$projectName\"

            Mock -CommandName Get-CacheItem -MockWith {
                return @{ RepositoryName = $repositoryName }
            } -ParameterFilter {
                $Type -eq 'LiveRepositories'
            }

            $result = Get-AzDoGitRepository -ProjectName $projectName -RepositoryName $repositoryName

            $result.status | Should -Be "Unchanged"
            $result.Ensure | Should -Be "Absent"
        }
    }

    Context "When repository does not exist in the live cache"  {

        It "should perform a lookup within the local cache" -skip {
            $projectName = "TestProject"
            $repositoryName = "TestRepository"
            $projectGroupKey = "$projectName\"

            Mock -CommandName Get-CacheItem -MockWith {
                return $null
            } -ParameterFilter {
                ($Key -eq $projectGroupKey) -and ($Type -eq 'Repositories')
            }

            $result = Get-AzDoGitRepository -ProjectName $projectName -RepositoryName $repositoryName

            Assert-MockCalled -CommandName Get-CacheItem -Times 2 -Exactly
        }

        It "should return NotFound status" {
            $projectName = "TestProject"
            $repositoryName = "TestRepository"
            $projectGroupKey = "$projectName\"

            Mock -CommandName Get-CacheItem -ParameterFilter {
                $Type -eq 'LiveRepositories'
            }

            $result = Get-AzDoGitRepository -ProjectName $projectName -RepositoryName $repositoryName

            $result.status | Should -Be "NotFound"
            $result.Ensure | Should -Be "Absent"
        }
    }
}
