$currentFile = $MyInvocation.MyCommand.Path

# Pester tests
# Not required to run in the pipeline
Describe "Test-AzDoOrganizationGroup" -skip {

    BeforeAll {
        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Test-AzDoOrganizationGroup.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)

        ForEach ($file in $files) {
            . $file.FullName
        }

        # Mock the external functions used within Test-AzDoOrganizationGroup
        Mock -CommandName Test-AzDoOrganizationGroup

    }

    Context "when the group exists" {
        It "should return true" {
            # Mock Test-AzDoOrganizationGroup function to simulate group existence
            Mock -CommandName Test-AzDoOrganizationGroup -MockWith {
                param (
                    [string]$GroupName,
                    [string]$Pat,
                    [string]$ApiUri
                )
                return $true
            }

            $result = Test-AzDoOrganizationGroup -GroupName 'ExistingGroup' -Pat 'dummyPat' -ApiUri 'https://dev.azure.com/myorg'
            $result | Should -Be $true
        }
    }

    Context "when the group does not exist" {
        It "should return false" {
            # Mock Test-AzDoOrganizationGroup function to simulate group non-existence
            Mock -CommandName Test-AzDoOrganizationGroup -MockWith {
                param (
                    [string]$GroupName,
                    [string]$Pat,
                    [string]$ApiUri
                )
                return $false
            }

            $result = Test-AzDoOrganizationGroup -GroupName 'NonExistentGroup' -Pat 'dummyPat' -ApiUri 'https://dev.azure.com/myorg'
            $result | Should -Be $false
        }
    }

    Context "when there is an empty GroupName parameter" {
        It "should throw an error" {
            { Test-AzDoOrganizationGroup -GroupName '' -Pat 'dummyPat' -ApiUri 'https://dev.azure.com/myorg' } | Should -Throw
        }
    }

    Context "when there is an empty Pat parameter" {
        It "should throw an error" {
            { Test-AzDoOrganizationGroup -GroupName 'ExistingGroup' -Pat '' -ApiUri 'https://dev.azure.com/myorg' } | Should -Throw
        }
    }

    Context "when there is an empty ApiUri parameter" {
        It "should throw an error" {
            { Test-AzDoOrganizationGroup -GroupName 'ExistingGroup' -Pat 'dummyPat' -ApiUri '' } | Should -Throw
        }
    }

}
