<#
    .SYNOPSIS
        Tests for the 'New-xAzDoProjectGroup' function to ensure it behaves as expected.

    .DESCRIPTION
        The tests will verify that the function correctly creates new groups, handles parameters,
        and updates the cache accordingly.
#>

Describe "New-xAzDoProjectGroup Tests" {

    Mock Export-Clixml {}
    Mock New-DevOpsGroup { return @{ principalName = "[$ProjectName]$GroupName"; description = $GroupDescription } }
    Mock Add-CacheItem {}
    Mock Set-CacheObject {}
    Mock Get-CacheItem { return @{ ProjectDescriptor = "ProjectDescriptor" } }

    BeforeEach {
        $GroupName = "Developers"
        $ProjectName = "ContosoProject"
        $GroupDescription = "A group of developers."
        $Ensure = [Ensure]::Present
        $LookupResult = @{}
        $Force = $false
    }

    It "Should create a new group with the specified properties" {
        $result = New-xAzDoProjectGroup -GroupName $GroupName -GroupDescription $GroupDescription -ProjectName $ProjectName

        $result.principalName | Should -BeExactly "[$ProjectName]$GroupName"
        $result.description | Should -BeExactly $GroupDescription
    }

    It "Should call 'New-DevOpsGroup' with correct parameters" {
        $expectedParams = @{
            GroupName = $GroupName
            GroupDescription = $GroupDescription
            ApiUri = "https://vssps.dev.azure.com/{0}" -f $Global:DSCAZDO_OrganizationName
            ProjectScopeDescriptor = "ProjectDescriptor"
        }

        Assert-MockCalled New-DevOpsGroup -ParameterFilter { $GroupName -eq $expectedParams['GroupName'] -and
                                                             $GroupDescription -eq $expectedParams['GroupDescription'] -and
                                                             $ApiUri -eq $expectedParams['ApiUri'] -and
                                                             $ProjectScopeDescriptor -eq $expectedParams['ProjectScopeDescriptor'] } -Times 1
    }

    It "Should add the new group to the 'LiveGroups' cache" {
        New-xAzDoProjectGroup -GroupName $GroupName -GroupDescription $GroupDescription -ProjectName $ProjectName

        Assert-MockCalled Add-CacheItem -ParameterFilter { $Key -eq "[$ProjectName]$GroupName" -and $Type -eq 'LiveGroups' } -Times 1
    }

    It "Should add the new group to the 'Group' cache" {
        New-xAzDoProjectGroup -GroupName $GroupName -GroupDescription $GroupDescription -ProjectName $ProjectName

        Assert-MockCalled Add-CacheItem -ParameterFilter { $Key -eq "[$ProjectName]$GroupName" -and $Type -eq 'Group' } -Times 1
    }

    It "Should update the global cache objects for 'LiveGroups' and 'Group'" {
        New-xAzDoProjectGroup -GroupName $GroupName -GroupDescription $GroupDescription -ProjectName $ProjectName

        Assert-MockCalled Set-CacheObject -ParameterFilter { $CacheType -eq 'LiveGroups' } -Times 1
        Assert-MockCalled Set-CacheObject -ParameterFilter { $CacheType -eq 'Group' } -Times 1
    }
}
