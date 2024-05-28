<#
    .SYNOPSIS
        Tests for the 'Get-xAzDoProjectGroup' function to ensure it behaves as expected.

    .DESCRIPTION
        The tests will verify that the function correctly retrieves groups, handles cache items,
        and processes conditions such as missing groups or properties changes.
#>

Describe "Get-xAzDoProjectGroup Tests" {

    Mock Format-AzDoGroup { return "FormattedName" }
    Mock Get-CacheItem {}
    Mock Remove-CacheItem {}
    Mock Add-CacheItem {}
    Mock Find-CacheItem {}

    BeforeEach {
        $GroupName = "Developers"
        $ProjectName = "ContosoProject"
        $GroupDescription = "A group of developers."
        $Ensure = [Ensure]::Present
        $LookupResult = @{}
    }

    It "Should retrieve a group with unchanged properties when both live and local caches match" {
        Mock Get-CacheItem { return @{ originId = "123"; description = $GroupDescription; name = $GroupName } }

        $result = Get-xAzDoProjectGroup -ProjectName $ProjectName -GroupName $GroupName -GroupDescription $GroupDescription

        $result.status | Should -BeExactly [DSCGetSummaryState]::Unchanged
        $result.Ensure | Should -BeExactly [Ensure]::Present
    }

    It "Should detect a renamed group when originIds differ" {
        Mock Get-CacheItem { if ($Type -eq 'LiveGroups') { return @{ originId = "123-live" } } else { return @{ originId = "123-local" } } }
        Mock Find-CacheItem { return @{ originId = "123-live"; description = $GroupDescription; name = $GroupName } }

        $result = Get-xAzDoProjectGroup -ProjectName $ProjectName -GroupName $GroupName -GroupDescription $GroupDescription

        $result.status | Should -BeExactly [DSCGetSummaryState]::Renamed
        $result.renamedGroup.name | Should -BeExactly $GroupName
    }

    It "Should detect a changed group when properties differ" {
        Mock Get-CacheItem { return @{ originId = "123"; description = "Old Description"; name = "Old Name" } }

        $result = Get-xAzDoProjectGroup -ProjectName $ProjectName -GroupName $GroupName -GroupDescription $GroupDescription

        $result.status | Should -BeExactly [DSCGetSummaryState]::Changed
        $result.propertiesChanged | Should -Contain "Description"
        $result.propertiesChanged | Should -Contain "Name"
    }

    It "Should handle a missing group when livegroup is absent and localgroup is present" {
        Mock Get-CacheItem { if ($Type -eq 'LiveGroups') { return $null } else { return @{ originId = "123-local" } } }

        $result = Get-xAzDoProjectGroup -ProjectName $ProjectName -GroupName $GroupName -GroupDescription $GroupDescription

        $result.status | Should -BeExactly [DSCGetSummaryState]::NotFound
    }

    It "Should handle a recreated group when localgroup is absent and livegroup is present" {
        Mock Get-CacheItem { if ($Type -eq 'LiveGroups') { return @{ originId = "123-live" } } else { return $null } }

        $result = Get-xAzDoProjectGroup -ProjectName $ProjectName -GroupName $GroupName -GroupDescription $GroupDescription

        $result.status | Should -BeExactly [DSCGetSummaryState]::Changed
        $result.Ensure | Should -BeExactly [Ensure]::Present
    }

    It "Should handle a completely missing group when both livegroup and localgroup are absent" {
        Mock Get-CacheItem { return $null }

        $result = Get-xAzDoProjectGroup -ProjectName $ProjectName -GroupName $GroupName -GroupDescription $GroupDescription

        $result.status | Should -BeExactly [DSCGetSummaryState]::NotFound
    }
}
