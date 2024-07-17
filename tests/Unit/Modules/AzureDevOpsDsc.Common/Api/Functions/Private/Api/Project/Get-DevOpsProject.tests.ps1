powershell
Describe 'Get-DevOpsProject' {
    Mock -CommandName Convert::ToBase64String -MockWith { return 'dGVzdAo=' }
    Mock -CommandName Invoke-RestMethod -MockWith { return @{ name = 'ProjectName'; id = 'ProjectId' } }

    $Organization = 'testOrg'
    $ProjectId = 'testProject'
    $PersonalAccessToken = 'testToken'

    Context 'When all parameters are provided' {
        It 'Should call Convert::ToBase64String with correct arguments' {
            Get-DevOpsProject -Organization $Organization -ProjectId $ProjectId -PersonalAccessToken $PersonalAccessToken
            Assert-MockCalled -CommandName Convert::ToBase64String -Exactly -Times 1 -Scope It
        }

        It 'Should call Invoke-RestMethod with correct arguments' {
            Get-DevOpsProject -Organization $Organization -ProjectId $ProjectId -PersonalAccessToken $PersonalAccessToken
            Assert-MockCalled -CommandName Invoke-RestMethod -Exactly -Times 1 -Scope It
        }

        It 'Should return the expected project details' {
            $result = Get-DevOpsProject -Organization $Organization -ProjectId $ProjectId -PersonalAccessToken $PersonalAccessToken
            $result.name | Should -Be 'ProjectName'
            $result.id | Should -Be 'ProjectId'
        }
    }

    Context 'When Invoke-RestMethod fails' {
        Mock -CommandName Invoke-RestMethod -MockWith { throw 'API Error' }

        It 'Should throw an error' {
            { Get-DevOpsProject -Organization $Organization -ProjectId $ProjectId -PersonalAccessToken $PersonalAccessToken } | Should -Throw
        }
    }
}

