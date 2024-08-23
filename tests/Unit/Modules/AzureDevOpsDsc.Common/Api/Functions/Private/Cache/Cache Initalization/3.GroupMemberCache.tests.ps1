$currentFile = $MyInvocation.MyCommand.Path

Describe 'AzDoAPI_3_GroupMemberCache' {

    BeforeAll {

        # Set the Project
        $null = Set-Variable -Name "AzDoProject" -Value @() -Scope Global

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath '3.GroupMemberCache.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        Mock -CommandName Get-CacheObject -MockWith {
            if ($CacheType -eq 'LiveGroups')
            {
                return @(
                    [PSCustomObject]@{ Key = 'Group1'; Value = [PSCustomObject]@{ descriptor = 'desc1'; PrincipalName = 'Group1' } },
                    [PSCustomObject]@{ Key = 'Group2'; Value = [PSCustomObject]@{ descriptor = 'desc2'; PrincipalName = 'Group2' } }
                )
            } elseif ($CacheType -eq 'LiveUsers') {
                return @(
                    [PSCustomObject]@{ descriptor = 'desc1'; PrincipalName = 'user1@example.com' },
                    [PSCustomObject]@{ descriptor = 'desc2'; PrincipalName = 'user2@example.com' }
                )
            }
        }

        Mock -CommandName List-DevOpsGroupMembers -MockWith {
            param (
                [string]$Organization,
                [string]$GroupDescriptor
            )
            return [PSCustomObject]@{ memberDescriptor = @('desc1', 'desc2') }
        }

        Mock -CommandName Add-CacheItem -MockWith {}
        Mock -CommandName Export-CacheObject -MockWith {}

    }

    Context 'when organization name parameter is provided' {

        It 'should call List-DevOpsGroupMembers with correct parameters' {
            AzDoAPI_3_GroupMemberCache -OrganizationName 'TestOrg'

            Assert-MockCalled -CommandName List-DevOpsGroupMembers -Exactly -Times 2 -Scope It -ParameterFilter {
                $Organization -eq 'TestOrg'
            }
        }

        It 'should add group members to cache' {
            AzDoAPI_3_GroupMemberCache -OrganizationName 'TestOrg'

            Assert-MockCalled -CommandName Add-CacheItem -Exactly -Times 2
        }

        It 'should export the cache' {
            AzDoAPI_3_GroupMemberCache -OrganizationName 'TestOrg'

            Assert-MockCalled -CommandName Export-CacheObject -Exactly -Times 1
        }
    }

    Context 'when organization name parameter is not provided' {

        BeforeEach {
            $Global:DSCAZDO_OrganizationName = 'GlobalTestOrg'
        }

        It 'should use the global organization name' {
            AzDoAPI_3_GroupMemberCache

            Assert-MockCalled -CommandName List-DevOpsGroupMembers -Exactly -Times 2 -ParameterFilter {
                $Organization -eq 'GlobalTestOrg'
            }
        }
    }

    Context 'when an error occurs' {

        BeforeAll {
            Mock -CommandName List-DevOpsGroupMembers -MockWith { throw "API Error" }
            Mock -CommandName Write-Error -Verifiable
        }

        It 'should catch and handle the error' {
            { AzDoAPI_3_GroupMemberCache -OrganizationName 'TestOrg' } | Should -Not -Throw
            Assert-VerifiableMock
        }
    }
}
