Describe 'Get-DevOpsProjects' {
    Mock -CommandName 'Invoke-RestMethod' {
        return @{
            value = @(
                @{ name = 'Project1'; id = '1'; state = 'wellFormed' }
                @{ name = 'Project2'; id = '2'; state = 'wellFormed' }
            )
        }
    }

    $Organization = 'TestOrg'
    $PersonalAccessToken = 'TestToken'

    Context 'When StateFilter is not provided' {
        It 'Should call Invoke-RestMethod with correct URI' {
            Get-DevOpsProjects -Organization $Organization -PersonalAccessToken $PersonalAccessToken

            Assert-MockCalled 'Invoke-RestMethod' -Exactly 1 -Scope It -ParameterFilter {
                $Uri -eq "https://dev.azure.com/$Organization/_apis/projects&api-version=7.2-preview.1" -and
                $Headers.Authorization -eq "Basic $([Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($PersonalAccessToken)")))"
            }
        }

        It 'Should return the list of projects' {
            $result = Get-DevOpsProjects -Organization $Organization -PersonalAccessToken $PersonalAccessToken

            $result | Should -HaveCount 2
            $result[0].name | Should -Be 'Project1'
            $result[1].name | Should -Be 'Project2'
        }
    }

    Context 'When StateFilter is provided' {
        It 'Should call Invoke-RestMethod with correct URI including StateFilter' {
            $StateFilter = 'wellFormed'
            Get-DevOpsProjects -Organization $Organization -PersonalAccessToken $PersonalAccessToken -StateFilter $StateFilter

            Assert-MockCalled 'Invoke-RestMethod' -Exactly 1 -Scope It -ParameterFilter {
                $Uri -eq "https://dev.azure.com/$Organization/_apis/projects?stateFilter=$StateFilter&api-version=7.2-preview.1" -and
                $Headers.Authorization -eq "Basic $([Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($PersonalAccessToken)")))"
            }
        }

        It 'Should return the list of projects' {
            $StateFilter = 'wellFormed'
            $result = Get-DevOpsProjects -Organization $Organization -PersonalAccessToken $PersonalAccessToken -StateFilter $StateFilter

            $result | Should -HaveCount 2
            $result[0].name | Should -Be 'Project1'
            $result[1].name | Should -Be 'Project2'
        }
    }
}

