
# Mock functions
Function List-DevOpsProjects {
    param (
        [string]$Organization
    )
    return @(
        @{Id = '1'; Name = 'Project1'},
        @{Id = '2'; Name = 'Project2'}
    )
}

Function Get-DevOpsSecurityDescriptor {
    param (
        [string]$ProjectId,
        [string]$Organization
    )
    return "SecurityDescriptor_$ProjectId"
}

Function Add-CacheItem {
    param (
        [string]$Key,
        [object]$Value,
        [string]$Type
    )
}

Function Export-CacheObject {
    param (
        [string]$CacheType,
        [object]$Content
    )
}

# Actual tests
Describe 'AzDoAPI_0_ProjectCache' {

    BeforeEach {
        $Global:DSCAZDO_OrganizationName = "GlobalOrganization"
    }

    It 'Should use organization name from parameter' {
        $script:paramsUsed = $null
        Mock List-DevOpsProjects { param($Organization) $script:paramsUsed = $Organization; return @(@{}); }

        AzDoAPI_0_ProjectCache -OrganizationName "TestOrg"
        $paramsUsed | Should -Be "TestOrg"
    }

    It 'Should use global organization name if parameter is not provided' {
        $script:paramsUsed = $null
        Mock List-DevOpsProjects { param($Organization) $script:paramsUsed = $Organization; return @(@{}); }

        AzDoAPI_0_ProjectCache
        $paramsUsed | Should -Be "GlobalOrganization"
    }

    It 'Should add projects to the cache' {
        $projectsAdded = @()
        Mock List-DevOpsProjects { return @(
            @{ Id = '1'; Name = 'Project1' },
            @{ Id = '2'; Name = 'Project2' }
        )}
        Mock Get-DevOpsSecurityDescriptor { param($ProjectId) return "SD_$ProjectId" }
        Mock Add-CacheItem { param($Key, $Value, $Type) $projectsAdded += $Key }

        AzDoAPI_0_ProjectCache -OrganizationName "TestOrg"
        $projectsAdded | Should -Contain "Project1", "Project2"
    }

    It 'Should export cache object' {
        $exportCalled = $false
        Mock Export-CacheObject { param($CacheType, $Content) $exportCalled = $true }

        AzDoAPI_0_ProjectCache -OrganizationName "TestOrg"
        $exportCalled | Should -Be $true
    }

    It 'Should handle errors gracefully' {
        Mock List-DevOpsProjects { throw "API Error" }
        Mock Write-Error {}

        { AzDoAPI_0_ProjectCache -OrganizationName "TestOrg" } | Should -Not -Throw
    }
}

