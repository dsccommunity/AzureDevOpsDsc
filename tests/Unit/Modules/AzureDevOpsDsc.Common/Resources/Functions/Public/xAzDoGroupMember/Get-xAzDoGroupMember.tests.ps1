$currentFile = $MyInvocation.MyCommand.Path

Describe "Get-xAzDoGroupMember Tests" {

    AfterAll {
        Remove-Variable -Name DSCAZDO_OrganizationName -Scope Global
    }

    BeforeAll {

        $Global:DSCAZDO_OrganizationName = 'TestOrganization'

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Get-xAzDoGroupMember.tests.ps1'
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

        # Mock dependencies
        Mock -CommandName Format-AzDoGroupMember -MockWith { return "MockKey" }
        Mock -CommandName Get-CacheItem -MockWith {
            return @(
                [PSCustomObject]@{ originId = "MockMember1" },
                [PSCustomObject]@{ originId = "MockMember2" }
            )
        }

        Mock -CommandName Find-AzDoIdentity -MockWith {
            param ([string]$Identity)
            return [PSCustomObject]@{ originId = $Identity }
        }

    }

    It "Handles group not found in live cache and no group members in parameters" {
        $params = @{
            GroupName    = "TestGroup"
            GroupMembers = @()
            LookupResult = @{}
            Ensure       = "Absent"
            Force        = $false
        }

        Mock -CommandName Get-CacheItem -MockWith { $null }

        $result = Get-xAzDoGroupMember @params
        $result.status | Should -Be ([DSCGetSummaryState]::Unchanged)
    }

    It "Handles group members in parameters but not found in live cache" {
        $params = @{
            GroupName    = "TestGroup"
            GroupMembers = @("Member1")
            LookupResult = @{}
            Ensure       = "Absent"
            Force        = $false
        }

        Mock -CommandName Get-CacheItem -MockWith { $null }

        $result = Get-xAzDoGroupMember @params
        $result.status | Should -Be ([DSCGetSummaryState]::NotFound)
    }

    It "Handles group members not found in live cache but are defined in parameters" {
        $params = @{
            GroupName    = "TestGroup"
            GroupMembers = @("Member1", "Member2")
            LookupResult = @{}
            Ensure       = "Absent"
            Force        = $false
        }

        Mock -CommandName Get-CacheItem -MockWith { $null }

        $result = Get-xAzDoGroupMember @params
        $result.status | Should -Be ([DSCGetSummaryState]::NotFound)
    }

    It "Handles no group members in parameters but live cache has members" {
        $params = @{
            GroupName    = "TestGroup"
            GroupMembers = @()
            LookupResult = @{}
            Ensure       = "Absent"
            Force        = $false
        }

        $result = Get-xAzDoGroupMember @params
        $result.status | Should -Be ([DSCGetSummaryState]::Missing)
    }

    It "Handles same group members in parameters and live cache" {

        Mock -CommandName Compare-Object

        $params = @{
            GroupName    = "TestGroup"
            GroupMembers = @("MockMember1", "MockMember2")
            LookupResult = @{}
            Ensure       = "Absent"
            Force        = $false
        }

        $result = Get-xAzDoGroupMember @params
        $result.status | Should -Be ([DSCGetSummaryState]::Unchanged)

    }

    It "Handles different members in live cache and parameters" {

        $params = @{
            GroupName    = "TestGroup"
            GroupMembers = @("MockMember1", "NewMember")
            LookupResult = @{}
            Ensure       = "Absent"
            Force        = $false
        }

        $result = Get-xAzDoGroupMember @params
        $result.status | Should -Be ([DSCGetSummaryState]::Changed)
        $result.propertiesChanged[0].action | Should -Be 'Remove'
        $result.propertiesChanged[0].value.originId | Should -Be 'MockMember2'
        $result.propertiesChanged[1].action | Should -Be 'Add'
        $result.propertiesChanged[1].value.originId | Should -Be 'NewMember'

    }

    # -Force is not used in the function logic directly.
    It "Handles different members in live cache and parameters with Force" -skip {

        $params = @{
            GroupName    = "TestGroup"
            GroupMembers = @("MockMember1", "NewMember")
            LookupResult = @{}
            Ensure       = "Absent"
            Force        = $true
        }

        $result = Get-xAzDoGroupMember @params
        $result.status | Should -Be ([DSCGetSummaryState]::Changed)
        $result.propertiesChanged[0].action | Should -Be 'Remove'
        $result.propertiesChanged[0].value.originId | Should -Be 'MockMember2'
        $result.propertiesChanged[1].action | Should -Be 'Add'
        $result.propertiesChanged[1].value.originId | Should -Be 'NewMember'

    }

}
