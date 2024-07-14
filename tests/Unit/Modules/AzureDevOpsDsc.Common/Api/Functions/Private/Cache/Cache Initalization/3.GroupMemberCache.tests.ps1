powershell
Import-Module Pester

Describe "AzDoAPI_3_GroupMemberCache" {
    
    Mock -CommandName Get-CacheObject {
        if ($args[0].CacheType -eq 'LiveGroups') {
            return @(
                @{Key = "Group1"; Value = @{descriptor = "groupdesc1"; PrincipalName = "Group1Name"}}
            )
        }
        if ($args[0].CacheType -eq 'LiveUsers') {
            return @{
                value = @(
                    @{descriptor = "userdesc1"; DisplayName = "User1"},
                    @{descriptor = "userdesc2"; DisplayName = "User2"}
                )
            }
        }
    }

    Mock -CommandName List-DevOpsGroupMembers {
        return @{
            memberDescriptor = @("userdesc1", "userdesc2")
        }
    }

    Mock -CommandName Add-CacheItem { }

    Mock -CommandName Export-CacheObject { }

    BeforeEach {
        $Global:DSCAZDO_OrganizationName = "TestOrg"
    }

    It "Uses organization name from parameter when provided" {
        $OrganizationName = "ParamOrg"
        AzDoAPI_3_GroupMemberCache -OrganizationName $OrganizationName

        Assert-MockCalled -CommandName List-DevOpsGroupMembers -Exactly 1 -Scope It -ParameterFilter {
            $OrganizationName -eq "ParamOrg" -and $GroupDescriptor -eq "groupdesc1"
        }
    }

    It "Uses global variable for organization name when parameter is not provided" {
        AzDoAPI_3_GroupMemberCache

        Assert-MockCalled -CommandName List-DevOpsGroupMembers -Exactly 1 -Scope It -ParameterFilter {
            $OrganizationName -eq "TestOrg" -and $GroupDescriptor -eq "groupdesc1"
        }
    }

    It "Adds members to cache" {
        AzDoAPI_3_GroupMemberCache -OrganizationName "TestOrg"

        Assert-MockCalled -CommandName Add-CacheItem -Exactly 1 -Scope It -ParameterFilter {
            $_.Key -eq "Group1Name" -and $_.Value.Count -eq 2 -and $_.Type -eq 'LiveGroupMembers'
        }
    }

    It "Exports cache to file" {
        AzDoAPI_3_GroupMemberCache -OrganizationName "TestOrg"

        Assert-MockCalled -CommandName Export-CacheObject -Exactly 1 -Scope It -ParameterFilter {
            $_.CacheType -eq 'LiveGroupMembers'
        }
    }
}

