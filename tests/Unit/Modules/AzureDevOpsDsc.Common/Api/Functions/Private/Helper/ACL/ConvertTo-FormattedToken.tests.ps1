$currentFile = $MyInvocation.MyCommand.Path

# ConvertTo-FormattedToken.Tests.ps1

Describe "ConvertTo-FormattedToken" -Tags "Unit", "ACL", "Helper" {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'ConvertTo-FormattedToken.tests.ps1'
        }

        # Load the functions to test
        $files = Get-FunctionItem (Find-MockedFunctions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

    }

    It "should format GitOrganization token correctly" {
        $token = @{
            type = 'GitOrganization'
        }

        $result = ConvertTo-FormattedToken -Token $token

        $result | Should -Be 'repoV2'
    }

    It "should format GitProject token correctly" {
        $token = @{
            type = 'GitProject'
            projectId = 'myProject'
        }

        $result = ConvertTo-FormattedToken -Token $token

        $result | Should -Be 'repoV2/myProject'
    }

    It "should format GitRepository token correctly" {
        $token = @{
            type = 'GitRepository'
            projectId = 'myProject'
            RepoId = 'myRepo'
        }

        $result = ConvertTo-FormattedToken -Token $token

        $result | Should -Be 'repoV2/myProject/myRepo'
    }

    It "should return an empty string for unrecognized token type" {
        $token = @{
            type = 'UnknownType'
        }

        $result = ConvertTo-FormattedToken -Token $token

        $result | Should -Be ''
    }

    It "should return an empty string for an empty token" {
        $token = @{}

        $result = ConvertTo-FormattedToken -Token $token

        $result | Should -Be ''
    }
}
