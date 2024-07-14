powershell
Describe "ConvertTo-FormattedToken" {
    BeforeAll {
        Import-Module "$PSScriptRoot\path_to_your_module.psm1"
    }

    It "should return formatted string for GitProject token" {
        $token = @{
            type = 'GitProject'
            projectId = 'myProject'
            repositoryId = 'myRepo'
        }
        $expected = 'repoV2/myProject'
        $result = ConvertTo-FormattedToken -Token $token
        $result | Should -Be $expected
    }

    It "should return formatted string for GitRepository token" {
        $token = @{
            type = 'GitRepository'
            projectId = 'myProject'
            RepoId = 'myRepo'
        }
        $expected = 'repoV2/myProject/myRepo'
        $result = ConvertTo-FormattedToken -Token $token
        $result | Should -Be $expected
    }

    It "should return formatted string for GitOrganization token" {
        $token = @{
            type = 'GitOrganization'
        }
        $expected = 'repoV2'
        $result = ConvertTo-FormattedToken -Token $token
        $result | Should -Be $expected
    }

    It "should return empty string for unrecognized token type" {
        $token = @{
            type = 'UnknownType'
        }
        $expected = ''
        $result = ConvertTo-FormattedToken -Token $token
        $result | Should -Be $expected
    }

    It "should return empty string when no type is provided" {
        $token = @{
            projectId = 'myProject'
            RepoId = 'myRepo'
        }
        $expected = ''
        $result = ConvertTo-FormattedToken -Token $token
        $result | Should -Be $expected
    }
}

