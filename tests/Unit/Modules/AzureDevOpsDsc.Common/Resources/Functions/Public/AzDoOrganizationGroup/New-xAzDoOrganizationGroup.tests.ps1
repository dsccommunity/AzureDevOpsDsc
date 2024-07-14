powershell
Describe 'New-xAzDoOrganizationGroup' {
    Mock -CommandName New-DevOpsGroup -MockWith {
        return [PSCustomObject]@{
            principalName = 'TestGroup'
            GroupName = $GroupName
            GroupDescription = $GroupDescription
        }
    }
    
    Mock -CommandName Add-CacheItem
    Mock -CommandName Set-CacheObject

    BeforeEach {
        $Global:DSCAZDO_OrganizationName = 'TestOrganization'
    }
    
    It 'Should create a new DevOps group and update caches' {
        $GroupName = 'TestGroup'
        $GroupDescription = 'Test Description'
        
        $result = New-xAzDoOrganizationGroup -GroupName $GroupName -GroupDescription $GroupDescription
    
        Assert-MockCalled -CommandName New-DevOpsGroup -Exactly 1 -Scope It
        Assert-MockCalled -CommandName Add-CacheItem -Exactly 2 -Scope It
        Assert-MockCalled -CommandName Set-CacheObject -Exactly 2 -Scope It
        
        $result | Should -Not -BeNullOrEmpty
    }

    It 'Should pass the correct parameters to New-DevOpsGroup' {
        $GroupName = 'TestGroup'
        $GroupDescription = 'Test Description'
        
        New-xAzDoOrganizationGroup -GroupName $GroupName -GroupDescription $GroupDescription

        $params = @{
            GroupName = $GroupName
            GroupDescription = $GroupDescription
            ApiUri = "https://vssps.dev.azure.com/TestOrganization"
        }

        Assert-MockCalled -CommandName New-DevOpsGroup -Exactly 1 -Scope It -ParameterFilter { $GroupName -eq $params.GroupName -and $GroupDescription -eq $params.GroupDescription -and $ApiUri -eq $params.ApiUri }
    }

    It 'Should add the group to the caches correctly' {
        New-xAzDoOrganizationGroup -GroupName 'TestGroup' -GroupDescription 'Test Description'

        Assert-MockCalled -CommandName Add-CacheItem -ParameterFilter {
            $Key -eq 'TestGroup' -and
            $Type -eq 'LiveGroups'
        } -Scope It

        Assert-MockCalled -CommandName Add-CacheItem -ParameterFilter {
            $Key -eq 'TestGroup' -and
            $Type -eq 'Group'
        } -Scope It

        Assert-MockCalled -CommandName Set-CacheObject -ParameterFilter {
            $CacheType -eq 'LiveGroups'
        } -Scope It

        Assert-MockCalled -CommandName Set-CacheObject -ParameterFilter {
            $CacheType -eq 'Group'
        } -Scope It
    }
}

