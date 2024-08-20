$currentFile = $MyInvocation.MyCommand.Path

Describe 'List-DevOpsGitRepository' {

    BeforeAll {
        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        Mock -CommandName Get-AzDevOpsApiVersion -MockWith { return '6.0' }
        Mock -CommandName Invoke-AzDevOpsApiRestMethod
    }

    It 'Returns repositories when API provides data' {
        $mockResult = @{
            value = @(
                @{name = 'Repo1'; id = '1'},
                @{name = 'Repo2'; id = '2'}
            )
        }

        Mock -CommandName Invoke-AzDevOpsApiRestMethod { return $mockResult }

        $result = List-DevOpsGitRepository -OrganizationName 'org' -ProjectName 'proj'

        $result | Should -HaveCount 2
        $result[0].name | Should -Be 'Repo1'
        $result[1].name | Should -Be 'Repo2'
    }

    It 'Returns null when API does not provide data' {

        Mock -CommandName Invoke-AzDevOpsApiRestMethod {
            return @{ value = $null }
        }

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

        Assert-MockCalled Invoke-AzDevOpsApiRestMethod -ParameterFilter {
            $Uri -eq "https://dev.azure.com/$dummyOrg/$dummyProj/_apis/git/repositories" -and
            $Method -eq 'Get'
        }
    }
}

