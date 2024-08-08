Describe 'List-DevOpsGitRepository' {
    Mock Get-AzDevOpsApiVersion { return "6.0" }
    Mock Invoke-AzDevOpsApiRestMethod

    Context 'When called with valid parameters' {
        $orgName = "testOrg"
        $projName = "testProj"

        It 'Should call Invoke-AzDevOpsApiRestMethod with correct parameters' {
            List-DevOpsGitRepository -OrganizationName $orgName -ProjectName $projName
            $params = @{
                Uri = "https://dev.azure.com/$orgName/$projName/_apis/git/repositories"
                Method = 'Get'
            }
            Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Exactly -Times 1 -Parameters $params
        }

        It 'Should return repositories values' {
            $expectedResult = @(
                @{ name = 'Repo1'; id = '1' },
                @{ name = 'Repo2'; id = '2' }
            )
            Mock Invoke-AzDevOpsApiRestMethod { @{ value = $expectedResult } }

            $result = List-DevOpsGitRepository -OrganizationName $orgName -ProjectName $projName

            $result | Should -Be $expectedResult
        }
    }

    Context 'When no repositories found' {
        $orgName = "testOrg"
        $projName = "testProj"

        It 'Should return $null' {
            Mock Invoke-AzDevOpsApiRestMethod { @{ value = $null } }

            $result = List-DevOpsGitRepository -OrganizationName $orgName -ProjectName $projName

            $result | Should -Be $null
        }
    }
}

