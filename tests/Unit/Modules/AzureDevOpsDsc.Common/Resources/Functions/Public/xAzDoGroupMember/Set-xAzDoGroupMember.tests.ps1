$currentFile = $MyInvocation.MyCommand.Path

Describe 'Set-AzDoGroupMember' {

    AfterAll {
        Remove-Variable -Name DSCAZDO_OrganizationName -Scope Global
        Remove-Variable -Name AzDoLiveGroupMembers -Scope Global
    }

    BeforeAll {

        $Global:DSCAZDO_OrganizationName = 'TestOrganization'
        $global:AzDoLiveGroupMembers = @{}

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Set-AzDoGroupMember.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)

        ForEach ($file in $files) {
            . $file.FullName
        }

        # Load the summary state
        . (Get-ClassFilePath 'DSCGetSummaryState')
        . (Get-ClassFilePath '000.CacheItem')
        . (Get-ClassFilePath 'Ensure')


        Mock -CommandName Find-AzDoIdentity -MockWith {
            return @{ principalName = "GroupName"; originId = "GroupOriginId"; displayName = "Test Group" }
        }
        Mock -CommandName Format-AzDoProjectName -MockWith {
            return "FormattedProjectName"
        }
        Mock -CommandName Get-CacheItem -MockWith {
            return @()
        }

        Mock -CommandName Get-Cacheitem -ParameterFilter { $Type -eq 'LiveGroupMembers' } -MockWith {
            return @(
                @{ principalName = 'user1'; originId = 'user1OriginId'; displayName = 'User 1' },
                @{ principalName = 'user2'; originId = 'user2OriginId'; displayName = 'User 2' }
            )
        }

        Mock -CommandName New-DevOpsGroupMember -MockWith {
            return $true
        }
        Mock -CommandName Remove-DevOpsGroupMember -MockWith {
            return $true
        }
        Mock -CommandName Add-CacheItem
        Mock -CommandName Set-CacheObject

        $LookupResult = @{
            propertiesChanged = @(
                @{ action = 'Add'; value = @{ principalName = 'user1'; originId = 'user1OriginId'; displayName = 'User 1' } },
                @{ action = 'Remove'; value = @{ principalName = 'user2'; originId = 'user2OriginId'; displayName = 'User 2' } }
            )
        }

    }

    Context 'When adding a group member' {

        It 'Should call New-DevOpsGroupMember with correct parameters' {

            Set-AzDoGroupMember -GroupName 'TestGroup' -LookupResult $LookupResult -Ensure 'Present'

            $params = @{
                GroupIdentity = @{
                    principalName = "GroupName";
                    originId = "GroupOriginId";
                    displayName = "Test Group"
                }
                ApiUri = 'https://vssps.dev.azure.com/{0}/' -f $Global:DSCAZDO_OrganizationName
                MemberIdentity = @{
                    principalName = 'user1';
                    originId = 'user1OriginId';
                    displayName = 'User 1'
                }
            }

            Assert-MockCalled -CommandName 'New-DevOpsGroupMember' -Exactly 1
        }

        It 'Should call Remove-DevOpsGroupMember with correct parameters' {
            Set-AzDoGroupMember -GroupName 'TestGroup' -LookupResult $LookupResult -Ensure 'Present'

            $params = @{
                GroupIdentity = @{
                    principalName = "GroupName";
                    originId = "GroupOriginId";
                    displayName = "Test Group"
                }
                ApiUri = 'https://vssps.dev.azure.com/{0}/' -f $Global:DSCAZDO_OrganizationName
                MemberIdentity = @{
                    principalName = 'user2';
                    originId = 'user2OriginId';
                    displayName = 'User 2'
                }
            }

            Assert-MockCalled -CommandName 'Remove-DevOpsGroupMember' -Exactly 1
        }

        it "should add and remove members" {
            Set-AzDoGroupMember -GroupName 'TestGroup' -LookupResult $LookupResult -Ensure 'Present'

            $params = @{
                GroupIdentity = @{
                    principalName = "GroupName";
                    originId = "GroupOriginId";
                    displayName = "Test Group"
                }
                ApiUri = 'https://vssps.dev.azure.com/{0}/' -f $Global:DSCAZDO_OrganizationName
                MemberIdentity = @{
                    principalName = 'user1';
                    originId = 'user1OriginId';
                    displayName = 'User 1'
                }
            }

            Assert-MockCalled -CommandName 'New-DevOpsGroupMember' -Exactly 1

            $params = @{
                GroupIdentity = @{
                    principalName = "GroupName";
                    originId = "GroupOriginId";
                    displayName = "Test Group"
                }
                ApiUri = 'https://vssps.dev.azure.com/{0}/' -f $Global:DSCAZDO_OrganizationName
                MemberIdentity = @{
                    principalName = 'user2';
                    originId = 'user2OriginId';
                    displayName = 'User 2'
                }
            }

            Assert-MockCalled -CommandName 'Remove-DevOpsGroupMember' -Exactly 1

        }

    }

    Context "when a circular reference is detected" {

        it "should ignore adding the member" {

            Mock Write-Warning -Verifiable

            $LookupResult = @{
                propertiesChanged = @(
                    @{ action = 'Add'; value = @{ principalName = 'user1'; originId = 'GroupOriginId'; displayName = 'User 1' } },
                    @{ action = 'Remove'; value = @{ principalName = 'user2'; originId = 'GroupOriginId'; displayName = 'User 2' } }
                )
            }

            Set-AzDoGroupMember -GroupName 'TestGroup' -LookupResult $LookupResult -Ensure 'Present'

            Assert-MockCalled -CommandName 'New-DevOpsGroupMember' -Exactly 0
            Assert-MockCalled -CommandName 'Remove-DevOpsGroupMember' -Exactly 0
            Assert-VerifiableMock

        }

        it "should ignore removing the member" {

            Mock Write-Warning -Verifiable

            $LookupResult = @{
                propertiesChanged = @(
                    @{ action = 'Add'; value = @{ principalName = 'user1'; originId = 'GroupOriginId'; displayName = 'User 1' } },
                    @{ action = 'Remove'; value = @{ principalName = 'user2'; originId = 'GroupOriginId'; displayName = 'User 2' } }
                )
            }

            Set-AzDoGroupMember -GroupName 'TestGroup' -LookupResult $LookupResult -Ensure 'Present'

            Assert-MockCalled -CommandName 'New-DevOpsGroupMember' -Exactly 0
            Assert-MockCalled -CommandName 'Remove-DevOpsGroupMember' -Exactly 0
            Assert-VerifiableMock

        }

    }

    Context "when functions called return '`$null'" {

        it "should not start when Get-CacheItem returns `$null" {

            Mock -CommandName Get-CacheItem -ParameterFilter { $Type -eq 'LiveGroupMembers' }
            Mock -CommandName Write-Error

            Set-AzDoGroupMember -GroupName 'TestGroup' -LookupResult $LookupResult -Ensure 'Present'

            Assert-MockCalled -CommandName 'Write-Error' -Exactly 1 -ParameterFilter { $Message -like '*LiveGroupMembers cache for group*' }
            Assert-MockCalled -CommandName 'New-DevOpsGroupMember' -Exactly 0
            Assert-MockCalled -CommandName 'Remove-DevOpsGroupMember' -Exactly 0

        }

        it "should not call New-DevOpsGroupMember" {

            Mock -CommandName New-DevOpsGroupMember -MockWith { return $null }

            Set-AzDoGroupMember -GroupName 'TestGroup' -LookupResult $LookupResult -Ensure 'Present'

            Assert-MockCalled -CommandName 'New-DevOpsGroupMember' -Exactly 1

        }

        it "should not call Remove-DevOpsGroupMember" {

            Mock -CommandName Remove-DevOpsGroupMember -MockWith { return $null }

            Set-AzDoGroupMember -GroupName 'TestGroup' -LookupResult $LookupResult -Ensure 'Present'

            Assert-MockCalled -CommandName 'Remove-DevOpsGroupMember' -Exactly 1

        }
    }

}
