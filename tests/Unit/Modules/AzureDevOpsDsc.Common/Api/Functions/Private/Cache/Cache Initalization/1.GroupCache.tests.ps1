
# Mock List-DevOpsGroups function
Function Mock-List-DevOpsGroups {
    param(
        [string]$Organization
    )

    return @(
        @{
            PrincipalName = "Group1"
            OtherProperty = "Value1"
        },
        @{
            PrincipalName = "Group2"
            OtherProperty = "Value2"
        }
    )
}

# Mock Add-CacheItem function
Function Mock-Add-CacheItem {
    param(
        [string]$Key,
        $Value,
        [string]$Type
    )
    # Simulate adding item to cache
    Write-Output "Cached $Key with type $Type"
}

# Mock Export-CacheObject function
Function Mock-Export-CacheObject {
    param(
        [string]$CacheType,
        $Content
    )
    # Simulate export cache to file
    Write-Output "Cache exported with type $CacheType"
}

# Import the Pester module
Import-Module Pester

Describe "AzDoAPI_1_GroupCache Tests" {
    BeforeAll {
        # Mock functions
        Mock List-DevOpsGroups { Mock-List-DevOpsGroups -Organization $Organization }
        Mock Add-CacheItem { Mock-Add-CacheItem -Key $Key -Value $Value -Type $Type }
        Mock Export-CacheObject { Mock-Export-CacheObject -CacheType $CacheType -Content $Content }

        # Function to test
        . $PSScriptRoot\AzDoAPI_1_GroupCache.ps1
    }

    It "should use global organization name if none is provided" {
        $Global:DSCAZDO_OrganizationName = "DefaultOrg"
        AzDoAPI_1_GroupCache

        # Assertions
        Should -Invoke List-DevOpsGroups -Exactly -ArgumentList @{ Organization = 'DefaultOrg' }
        Should -Invoke Add-CacheItem -Times 2
        Should -Invoke Export-CacheObject -Once
    }

    It "should use provided organization name" {
        AzDoAPI_1_GroupCache -OrganizationName "MyOrg"

        # Assertions
        Should -Invoke List-DevOpsGroups -Exactly -ArgumentList @{ Organization = 'MyOrg' }
        Should -Invoke Add-CacheItem -Times 2
        Should -Invoke Export-CacheObject -Once
    }

    It "should call Add-CacheItem for each group" {
        AzDoAPI_1_GroupCache -OrganizationName "MyOrg"

        # Assertions
        Should -Invoke Add-CacheItem -Times 2 -Exactly -ArgumentList @{
            Key = 'Group1'
            Value = @{
                PrincipalName = 'Group1'
                OtherProperty = 'Value1'
            }
            Type = 'LiveGroups'
        }
        Should -Invoke Add-CacheItem -Times 2 -Exactly -ArgumentList @{
            Key = 'Group2'
            Value = @{
                PrincipalName = 'Group2'
                OtherProperty = 'Value2'
            }
            Type = 'LiveGroups'
        }
    }

    It "should export cache after adding groups" {
        AzDoAPI_1_GroupCache -OrganizationName "MyOrg"

        # Assertions
        Should -Invoke Export-CacheObject -Exactly -ArgumentList @{
            CacheType = 'LiveGroups'
            Content = $null  # Assuming `$AzDoLiveGroups` can be $null in this context
        }
    }
}



