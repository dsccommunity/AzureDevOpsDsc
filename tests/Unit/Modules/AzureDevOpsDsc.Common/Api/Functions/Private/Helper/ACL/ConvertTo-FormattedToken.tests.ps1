$currentFile = $MyInvocation.MyCommand.Path

# ConvertTo-FormattedToken.Tests.ps1

Describe "ConvertTo-FormattedToken" -Tags "Unit", "ACL", "Helper" {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'ConvertTo-FormattedToken.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

    }

    It "should format GitOrganization token correctly" {
        $token = @{
            type = 'GitOrganization'
        }

        Mock -CommandName ConvertTo-FormattedToken -ParameterFilter { $Token.type -eq 'GitOrganization' } -MockWith { return 'repoV2' }

        $result = ConvertTo-FormattedToken -Token $token

        $result | Should -Be 'repoV2'
    }

    It "should format GitProject token correctly" {
        $token = @{
            type = 'GitProject'
            projectId = 'myProject'
        }

        Mock -CommandName ConvertTo-FormattedToken -ParameterFilter { $Token.type -eq 'GitProject' -and $Token.projectId -eq 'myProject' } -MockWith { return 'repoV2/myProject' }

        $result = ConvertTo-FormattedToken -Token $token

        $result | Should -Be 'repoV2/myProject'
    }

    It "should format GitRepository token correctly" {
        $token = @{
            type = 'GitRepository'
            projectId = 'myProject'
            RepoId = 'myRepo'
        }

        Mock -CommandName ConvertTo-FormattedToken -ParameterFilter { $Token.type -eq 'GitRepository' -and $Token.projectId -eq 'myProject' -and $Token.RepoId -eq 'myRepo' } -MockWith { return 'repoV2/myProject/myRepo' }

        $result = ConvertTo-FormattedToken -Token $token

        $result | Should -Be 'repoV2/myProject/myRepo'
    }

    It "should return an empty string for unrecognized token type" {
        $token = @{
            type = 'UnknownType'
        }

        Mock -CommandName ConvertTo-FormattedToken -ParameterFilter { $Token.type -eq 'UnknownType' } -MockWith { return '' }

        $result = ConvertTo-FormattedToken -Token $token

        $result | Should -Be ''
    }

    It "should return an empty string for an empty token" {
        $token = @{}

        Mock -CommandName ConvertTo-FormattedToken -ParameterFilter { $null -eq $Token.type } -MockWith { return '' }

        $result = ConvertTo-FormattedToken -Token $token

        $result | Should -Be ''
    }
}
