Describe "Find-AzDoIdentity" {
    BeforeAll {
        function Get-CacheItem {
            param (
                [Parameter(Mandatory)]
                [string]$Key,
                [Parameter(Mandatory)]
                [string]$Type
            )
            if ($Type -eq 'LiveUsers') {
                return @{
                    displayName = "test.user"
                    emailAddress = "test@domain.com"
                }
            } elseif ($Type -eq 'LiveGroups') {
                return @{
                    displayName = "test.group"
                }
            }
        }

        $Global:AZDOLiveUsers = @(
            @{
                key = "testuser"
                value = @{
                    displayName = "Test User"
                    emailAddress = "test.user@domain.com"
                }
            }
        )

        $Global:AZDOLiveGroups = @(
            @{
                key = "testgroup"
                value = @{
                    displayName = "Test Group"
                }
            }
        )
    }

    It "Should return user for email input" {
        $result = Find-AzDoIdentity -Identity 'test.user@domain.com' -Verbose
        $result.emailAddress | Should -Be 'test@domain.com'
    }

    It "Should return group for name with slashes" {
        $result = Find-AzDoIdentity -Identity 'Project/TestGroup' -Verbose
        $result.displayName | Should -Be 'test.group'
    }

    It "Should return user for display name" {
        $result = Find-AzDoIdentity -Identity 'Test User' -Verbose
        $result.displayName | Should -Be 'Test User'
    }

    It "Should return group for display name" {
        $result = Find-AzDoIdentity -Identity 'Test Group' -Verbose
        $result.displayName | Should -Be 'Test Group'
    }

    It "Should return warning for multiple users" {
        $Global:AZDOLiveUsers = @(
            @{
                key = "testuser1"
                value = @{
                    displayName = "Duplicate User"
                    emailAddress = "test1@domain.com"
                }
            },
            @{
                key = "testuser2"
                value = @{
                    displayName = "Duplicate User"
                    emailAddress = "test2@domain.com"
                }
            }
        )
        $result = { Find-AzDoIdentity -Identity 'Duplicate User' -Verbose } | Should -Throw
    }

    It "Should return warning for multiple groups" {
        $Global:AZDOLiveGroups = @(
            @{
                key = "testgroup1"
                value = @{
                    displayName = "Duplicate Group"
                }
            },
            @{
                key = "testgroup2"
                value = @{
                    displayName = "Duplicate Group"
                }
            }
        )
        $result = { Find-AzDoIdentity -Identity 'Duplicate Group' -Verbose } | Should -Throw
    }

    AfterAll {
        Remove-Variable -Name Global:AZDOLiveUsers
        Remove-Variable -Name Global:AZDOLiveGroups
    }
}

