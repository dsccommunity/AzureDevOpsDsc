$currentFile = $MyInvocation.MyCommand.Path

Describe 'AzDoAPI_2_UserCache' {

    BeforeAll {

        # Set the Project
        $null = Set-Variable -Name "AzDoProject" -Value @() -Scope Global

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Add-CacheItem.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }


        Mock -CommandName List-UserCache -MockWith {
            return @(
                [PSCustomObject]@{ PrincipalName = 'user1@example.com' },
                [PSCustomObject]@{ PrincipalName = 'user2@example.com' }
            )
        }

        Mock -CommandName Add-CacheItem
        Mock -CommandName Export-CacheObject

    }

    Context 'when organization name parameter is provided' {

        It 'should call List-UserCache with correct parameters' {
            AzDoAPI_2_UserCache -OrganizationName 'TestOrg'
            Assert-MockCalled -CommandName List-UserCache -Exactly -Times 1
        }

        It 'should add users to cache' {
            AzDoAPI_2_UserCache -OrganizationName 'TestOrg'

            Assert-MockCalled -CommandName Add-CacheItem -Exactly -Times 2
            Assert-MockCalled -CommandName Add-CacheItem -ParameterFilter {
                $Key -eq 'user1@example.com'
            }
            Assert-MockCalled -CommandName Add-CacheItem -ParameterFilter {
                $Key -eq 'user2@example.com'
            }
        }

        It 'should export the cache' {
            AzDoAPI_2_UserCache -OrganizationName 'TestOrg'

            Assert-MockCalled -CommandName Export-CacheObject -Exactly -Times 1
        }
    }

    Context 'when organization name parameter is not provided' {

        BeforeEach {
            $Global:DSCAZDO_OrganizationName = 'GlobalTestOrg'
        }

        It 'should use the global organization name' {
            AzDoAPI_2_UserCache
            Assert-MockCalled -CommandName List-UserCache -Exactly -Times 1
        }
    }

    Context 'when an error occurs' {

        BeforeAll {
            Mock -CommandName Write-Error -Verifiable
            Mock -CommandName List-UserCache -MockWith { throw "API Error" }
        }

        It 'should catch and handle the error' {
            { AzDoAPI_2_UserCache -OrganizationName 'TestOrg' } | Should -Not -Throw
        }
    }
}
