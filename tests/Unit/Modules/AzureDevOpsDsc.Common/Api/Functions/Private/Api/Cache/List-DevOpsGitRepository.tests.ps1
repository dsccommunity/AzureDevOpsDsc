
Describe 'List-DevOpsGitRepository' {
    Mock -ModuleName 'AzDevOps' -Name 'Get-AzDevOpsApiVersion' -MockWith { return '6.0' }
    Mock -ModuleName 'AzDevOps' -Name 'Invoke-AzDevOpsApiRestMethod'

    It 'Returns repositories when API provides data' {
        $mockResult = @{
            value = @(
                @{name = 'Repo1'; id = '1'},
                @{name = 'Repo2'; id = '2'}
            )
        }

        Mock Invoke-AzDevOpsApiRestMethod { return $mockResult }

        $result = List-DevOpsGitRepository -OrganizationName 'org' -ProjectName 'proj'

        $result | Should -HaveCount 2
        $result[0].name | Should -Be 'Repo1'
        $result[1].name | Should -Be 'Repo2'
    }

    It 'Returns null when API does not provide data' {
        $mockResult = @{
            value = $null
        }

        Mock Invoke-AzDevOpsApiRestMethod { return $mockResult }

        $result = List-DevOpsGitRepository -OrganizationName 'org' -ProjectName 'proj'

        $result | Should -Be $null
    }

    It 'Uses default API version if not provided' {
        $result = List-DevOpsGitRepository -OrganizationName 'org' -ProjectName 'proj'

        Assert-MockCalled Get-AzDevOpsApiVersion -Exactly 1
    }

    It 'Uses provided API version' {
        $customApiVersion = '5.1'

        $result = List-DevOpsGitRepository -OrganizationName 'org' -ProjectName 'proj' -ApiVersion $customApiVersion

        Assert-MockCalled Get-AzDevOpsApiVersion -Exactly 0
    }

    It 'Calls the REST API with correct parameters' {
        $dummyOrg = 'dummyOrg'
        $dummyProj = 'dummyProj'

        List-DevOpsGitRepository -OrganizationName $dummyOrg -ProjectName $dummyProj

        Assert-MockCalled Invoke-AzDevOpsApiRestMethod -ParameterFilter { $Uri -eq "https://dev.azure.com/$dummyOrg/$dummyProj/_apis/git/repositories" -and $Method -eq 'Get' }
    }
}

