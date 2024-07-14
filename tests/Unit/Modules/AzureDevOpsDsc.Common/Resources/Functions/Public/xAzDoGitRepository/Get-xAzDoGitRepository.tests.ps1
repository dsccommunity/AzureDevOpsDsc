powershell
Describe "Get-xAzDoGitRepository Tests" {
    Mock Get-CacheItem

    BeforeEach {
        Clear-Mock
    }

    Context "When repository exists in the live cache" {
        It "should return repository from the live cache with Unchanged status" {
            $projectName = "TestProject"
            $repositoryName = "TestRepository"
            $projectGroupKey = "$projectName\$repositoryName"

            Mock Get-CacheItem {
                return @{ RepositoryName = $repositoryName }
            } -ParameterFilter {
                $_.Key -eq $projectGroupKey -and $_.Type -eq 'LiveRepositories'
            }

            $result = Get-xAzDoGitRepository -ProjectName $projectName -RepositoryName $repositoryName

            $result.status | Should -Be "Unchanged"
            $result.Ensure | Should -Be "Absent"
        }
    }

    Context "When repository does not exist in the live cache" {
        It "should return NotFound status" {
            $projectName = "TestProject"
            $repositoryName = "TestRepository"
            $projectGroupKey = "$projectName\$repositoryName"

            Mock Get-CacheItem {
                return $null
            } -ParameterFilter {
                $_.Key -eq $projectGroupKey -and $_.Type -eq 'LiveRepositories'
            }

            $result = Get-xAzDoGitRepository -ProjectName $projectName -RepositoryName $repositoryName

            $result.status | Should -Be "NotFound"
            $result.Ensure | Should -Be "Absent"
        }
    }
}

