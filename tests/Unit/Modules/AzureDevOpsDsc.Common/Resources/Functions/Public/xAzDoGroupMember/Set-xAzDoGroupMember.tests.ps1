powershell
Describe 'Set-xAzDoGroupMember' {
    Mock -CommandName 'Find-AzDoIdentity' -MockWith { 
        return @{ principalName = "GroupName"; originId = "GroupOriginId"; displayName = "Test Group" } 
    }
    Mock -CommandName 'Format-AzDoProjectName' -MockWith { 
        return "FormattedProjectName" 
    }
    Mock -CommandName 'Get-CacheItem' -MockWith { 
        return @() 
    }
    Mock -CommandName 'New-DevOpsGroupMember' -MockWith { 
        return $true 
    }
    Mock -CommandName 'Remove-DevOpsGroupMember' -MockWith { 
        return $true 
    }
    Mock -CommandName 'Add-CacheItem'
    Mock -CommandName 'Set-CacheObject'
    
    $LookupResult = @{
        propertiesChanged = @(
            @{ action = 'Add'; value = @{ principalName = 'user1'; originId = 'user1OriginId'; displayName = 'User 1' } },
            @{ action = 'Remove'; value = @{ principalName = 'user2'; originId = 'user2OriginId'; displayName = 'User 2' } }
        )
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

