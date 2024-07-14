powershell
Describe "Find-AzDoIdentity" {

    BeforeAll {
        $Global:AZDOLiveUsers = @(
            [PSCustomObject]@{ value = [PSCustomObject]@{ displayName = "John Doe"; UPN = "johndoe@example.com" } },
            [PSCustomObject]@{ value = [PSCustomObject]@{ displayName = "Jane Doe"; UPN = "janedoe@example.com" } }
        )
        $Global:AZDOLiveGroups = @(
            [PSCustomObject]@{ value = [PSCustomObject]@{ displayName = "Project Team"; GroupName = "[Project]\Team" } }
        )

        function Get-CacheItem {
            param (
                [string]$Key,
                [string]$Type
            )
            switch ($Type) {
                'LiveUsers' {
                    return $Global:AZDOLiveUsers | Where-Object { $_.value.UPN -eq $Key }
                }
                'LiveGroups' {
                    return $Global:AZDOLiveGroups | Where-Object { $_.value.GroupName -eq $Key }
                }
            }
        }
    }

    It "Should return user details if identity is an email address" {
        $result = Find-AzDoIdentity -Identity "johndoe@example.com"
        $result.value.displayName | Should -Be "John Doe"
    }

    It "Should return group details if identity is a group name with backslash" {
        $result = Find-AzDoIdentity -Identity "Project\Team"
        $result.value.displayName | Should -Be "Project Team"
    }

    It "Should return group details if identity is a group name with forward slash" {
        $result = Find-AzDoIdentity -Identity "Project/Team"
        $result.value.displayName | Should -Be "Project Team"
    }

    It "Should return user details using display name" {
        $result = Find-AzDoIdentity -Identity "Jane Doe"
        $result.displayName | Should -Be "Jane Doe"
    }

    It "Should return warning if multiple users with same display name" {
        $Global:AZDOLiveUsers += [PSCustomObject]@{ value = [PSCustomObject]@{ displayName = "Duplicate Name"; UPN = "dup1@example.com" } }
        $Global:AZDOLiveUsers += [PSCustomObject]@{ value = [PSCustomObject]@{ displayName = "Duplicate Name"; UPN = "dup2@example.com" } }
        
        { Find-AzDoIdentity -Identity "Duplicate Name" } | Should -Throw
    }

    AfterAll {
        Remove-Variable -Name AZDOLiveUsers -Scope Global
        Remove-Variable -Name AZDOLiveGroups -Scope Global
    }
}

