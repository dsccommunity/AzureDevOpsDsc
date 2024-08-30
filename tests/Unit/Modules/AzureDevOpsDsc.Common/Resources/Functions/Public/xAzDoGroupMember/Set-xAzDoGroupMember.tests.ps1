$currentFile = $MyInvocation.MyCommand.Path

Describe 'Set-xAzDoGroupMember' {

    AfterAll {
        Remove-Variable -Name DSCAZDO_OrganizationName -Scope Global
        Remove-Variable -Name AzDoLiveGroupMembers -Scope Global
    }

    BeforeAll {

        $Global:DSCAZDO_OrganizationName = 'TestOrganization'
        $global:AzDoLiveGroupMembers = @{}

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Set-xAzDoGroupMember.tests.ps1'
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

            Set-xAzDoGroupMember -GroupName 'TestGroup' -LookupResult $LookupResult -Ensure 'Present'

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

            Assert-MockCalled -CommandName 'New-DevOpsGroupMember' -Exactly 1 -Scope It
        }

        It 'Should call Remove-DevOpsGroupMember with correct parameters' {
            Set-xAzDoGroupMember -GroupName 'TestGroup' -LookupResult $LookupResult -Ensure 'Present'

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

            Assert-MockCalled -CommandName 'Remove-DevOpsGroupMember' -Exactly 1 -Scope It
        }
    }
}
