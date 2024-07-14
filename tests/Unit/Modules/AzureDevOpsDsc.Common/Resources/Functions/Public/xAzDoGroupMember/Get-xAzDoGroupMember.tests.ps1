powershell
Describe "Get-xAzDoGroupMember Tests" {

    # Mock dependencies
    Mock -CommandName Format-AzDoProjectName -MockWith {
        param ([string]$GroupName, [string]$OrganizationName)
        return "MockKey"
    }

    Mock -CommandName Get-CacheItem -MockWith {
        param ([string]$Key, [string]$Type)
        return @("MockMember1", "MockMember2")
    }

    Mock -CommandName Find-AzDoIdentity -MockWith {
        param ([string]$Member)
        return [PSCustomObject]@{ originId = $Member }
    }

    It "Handles group not found in live cache and no group members in parameters" {
        $params = @{
            GroupName = "TestGroup"
            GroupMembers = @()
            LookupResult = @{}
            Ensure = "Absent"
            Force = $false
        }

        Mock -CommandName Get-CacheItem -MockWith { $null }

        $result = Get-xAzDoGroupMember @params
        $result.status | Should -Be ([DSCGetSummaryState]::Unchanged)
    }

    It "Handles group members in parameters but not found in live cache" {
        $params = @{
            GroupName = "TestGroup"
            GroupMembers = @("Member1")
            LookupResult = @{}
            Ensure = "Absent"
            Force = $false
        }

        Mock -CommandName Get-CacheItem -MockWith { $null }

        $result = Get-xAzDoGroupMember @params
        $result.status | Should -Be ([DSCGetSummaryState]::NotFound)
    }

    It "Handles group members not found in live cache but are defined in parameters" {
        $params = @{
            GroupName = "TestGroup"
            GroupMembers = @("Member1", "Member2")
            LookupResult = @{}
            Ensure = "Absent"
            Force = $false
        }

        Mock -CommandName Get-CacheItem -MockWith { $null }

        $result = Get-xAzDoGroupMember @params
        $result.status | Should -Be ([DSCGetSummaryState]::NotFound)
    }

    It "Handles no group members in parameters but live cache has members" {
        $params = @{
            GroupName = "TestGroup"
            GroupMembers = @()
            LookupResult = @{}
            Ensure = "Absent"
            Force = $false
        }

        $result = Get-xAzDoGroupMember @params
        $result.status | Should -Be ([DSCGetSummaryState]::Missing)
    }

    It "Handles same group members in parameters and live cache" {
        $params = @{
            GroupName = "TestGroup"
            GroupMembers = @("MockMember1", "MockMember2")
            LookupResult = @{}
            Ensure = "Absent"
            Force = $false
        }

        $result = Get-xAzDoGroupMember @params
        $result.status | Should -Be ([DSCGetSummaryState]::Unchanged)
    }

    It "Handles different members in live cache and parameters" {
        $params = @{
            GroupName = "TestGroup"
            GroupMembers = @("MockMember1", "NewMember")
            LookupResult = @{}
            Ensure = "Absent"
            Force = $false
        }

        $result = Get-xAzDoGroupMember @params
        $result.status | Should -Be ([DSCGetSummaryState]::Changed)
        $result.propertiesChanged[0].action | Should -Be 'Remove'
        $result.propertiesChanged[0].value.originId | Should -Be 'MockMember2'
        $result.propertiesChanged[1].action | Should -Be 'Add'
        $result.propertiesChanged[1].value.originId | Should -Be 'NewMember'
    }
}

