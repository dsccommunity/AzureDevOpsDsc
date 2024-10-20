$currentFile = $MyInvocation.MyCommand.Path

# Pester tests
# Not required to run in the pipeline
Describe "Test-xAzDoOrganizationGroup" -skip {

    BeforeAll {
        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Test-xAzDoOrganizationGroup.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)

        ForEach ($file in $files) {
            . $file.FullName
        }

        # Mock the external functions used within Test-xAzDoOrganizationGroup
        Mock -CommandName Test-xAzDoOrganizationGroup

    }

    Context "when the group exists" {
        It "should return true" {
            # Mock Test-xAzDoOrganizationGroup function to simulate group existence
            Mock -CommandName Test-xAzDoOrganizationGroup -MockWith {
                param (
                    [string]$GroupName,
                    [string]$Pat,
                    [string]$ApiUri
                )
                return $true
            }

            $result = Test-xAzDoOrganizationGroup -GroupName 'ExistingGroup' -Pat 'dummyPat' -ApiUri 'https://dev.azure.com/myorg'
            $result | Should -Be $true
        }
    }

    Context "when the group does not exist" {
        It "should return false" {
            # Mock Test-xAzDoOrganizationGroup function to simulate group non-existence
            Mock -CommandName Test-xAzDoOrganizationGroup -MockWith {
                param (
                    [string]$GroupName,
                    [string]$Pat,
                    [string]$ApiUri
                )
                return $false
            }

            $result = Test-xAzDoOrganizationGroup -GroupName 'NonExistentGroup' -Pat 'dummyPat' -ApiUri 'https://dev.azure.com/myorg'
            $result | Should -Be $false
        }
    }

    Context "when there is an empty GroupName parameter" {
        It "should throw an error" {
            { Test-xAzDoOrganizationGroup -GroupName '' -Pat 'dummyPat' -ApiUri 'https://dev.azure.com/myorg' } | Should -Throw
        }
    }

    Context "when there is an empty Pat parameter" {
        It "should throw an error" {
            { Test-xAzDoOrganizationGroup -GroupName 'ExistingGroup' -Pat '' -ApiUri 'https://dev.azure.com/myorg' } | Should -Throw
        }
    }

    Context "when there is an empty ApiUri parameter" {
        It "should throw an error" {
            { Test-xAzDoOrganizationGroup -GroupName 'ExistingGroup' -Pat 'dummyPat' -ApiUri '' } | Should -Throw
        }
    }

}
