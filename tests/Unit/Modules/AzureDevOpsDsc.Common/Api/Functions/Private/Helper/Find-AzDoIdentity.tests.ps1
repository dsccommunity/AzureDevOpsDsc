$currentFile = $MyInvocation.MyCommand.Path

Describe "Find-AzDoIdentity" {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath "ConvertTo-Base64String.tests.ps1"
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        . (Get-ClassFilePath '000.CacheItem')

        # Mocking Get-CacheItem to simulate cache retrieval
        Mock -CommandName Get-CacheItem -MockWith {
            param ($Key, $Type)

            switch ($Type)
            {
                'LiveUsers'
                {
                    if ($Key -eq 'user@domain.com')
                    {
                        return @{
                            ACLIdentity = @{
                                descriptor = "userDescriptor"
                                id = "userId"
                            }
                            originId = "userOriginId"
                            principalName = "userPrincipalName"
                            displayName = "User Display Name"
                        }
                    }
                    return $null
                }
                'LiveGroups'
                {
                    if ($Key -eq '[Project]\GroupName')
                    {
                        return @{
                            ACLIdentity = @{
                                descriptor = "groupDescriptor"
                                id = "groupId"
                            }
                            originId = "groupOriginId"
                            principalName = "groupPrincipalName"
                            displayName = "Group Display Name"
                        }
                    }
                    return $null
                }
            }
        }

        Mock Write-Verbose
        Mock Write-Warning

        $Global:AZDOLiveUsers = @(
            @{
                key = "user1"
                value = @{
                    ACLIdentity = @{
                        descriptor = "descriptor1"
                        id = "id1"
                    }
                    originId = "originId1"
                    principalName = "principalName1"
                    displayName = "User One"
                }
            },
            @{
                key = "user2"
                value = @{
                    ACLIdentity = @{
                        descriptor = "descriptor2"
                        id = "id2"
                    }
                    originId = "originId2"
                    principalName = "principalName2"
                    displayName = "User Two"
                }
            }
        )

        $Global:AZDOLiveGroups = @(
            @{
                key = "group1"
                value = @{
                    ACLIdentity = @{
                        descriptor = "descriptor1"
                        id = "id1"
                    }
                    originId = "originId1"
                    principalName = "principalName1"
                    displayName = "Group One"
                }
            },
            @{
                key = "group2"
                value = @{
                    ACLIdentity = @{
                        descriptor = "descriptor2"
                        id = "id2"
                    }
                    originId = "originId2"
                    principalName = "principalName2"
                    displayName = "Group Two"
                }
            }
        )
    }

    It "Should find user by email address" {
        $result = Find-AzDoIdentity -Identity 'user@domain.com'
        $result.ACLIdentity.descriptor | Should -Be 'userDescriptor'
    }

    It "Should find group by name with backslash" {
        $result = Find-AzDoIdentity -Identity 'Project\GroupName'
        $result.ACLIdentity.descriptor | Should -Be 'groupDescriptor'
    }

    It "Should find group by name with forward slash" {
        $result = Find-AzDoIdentity -Identity 'Project/GroupName'
        $result.ACLIdentity.descriptor | Should -Be 'groupDescriptor'
    }

    It "Should find user by display name" {
        $result = Find-AzDoIdentity -Identity 'User One'
        $result.displayName | Should -Be 'User One'
    }

    It "Should find group by display name" {
        $result = Find-AzDoIdentity -Identity 'Group One'
        $result.displayName | Should -Be 'Group One'
    }

    It "Should handle multiple users with the same display name" {
        Mock -CommandName 'Where-Object' -MockWith {
            param ($condition)
            return @($Global:AZDOLiveUsers[0], $Global:AZDOLiveUsers[1])
        }
        $result = Find-AzDoIdentity -Identity 'User One'
        $result | Should -BeNullOrEmpty
    }

    It "Should handle multiple groups with the same display name" {
        Mock -CommandName 'Where-Object' -MockWith {
            param ($condition)
            return @($Global:AZDOLiveGroups[0], $Global:AZDOLiveGroups[1])
        }

        $result = Find-AzDoIdentity -Identity 'Group One'
        $result | Should -BeNullOrEmpty
    }

    It "Should handle both user and group with the same display name" {
        Mock -CommandName 'Where-Object' -MockWith {
            param ($condition)
            if ($condition -like "*User One*") {
                return $Global:AZDOLiveUsers[0]
            } elseif ($condition -like "*Group One*") {
                return $Global:AZDOLiveGroups[0]
            }
        }

        $result = Find-AzDoIdentity -Identity 'User One'
        $result | Should -BeNullOrEmpty
    }

    It "Should return null if no identity found" {
        $result = Find-AzDoIdentity -Identity 'NonExistent'
        $result | Should -BeNullOrEmpty
    }

    It "Should throw identity is null" {
        { Find-AzDoIdentity -Identity $null } | Should -Throw
    }
}
