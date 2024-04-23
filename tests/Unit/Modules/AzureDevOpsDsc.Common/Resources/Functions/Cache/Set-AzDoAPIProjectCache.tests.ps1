
. $PSScriptRoot\..\..\..\..\AzureDevOpsDsc.Common.Tests.Initialization.ps1

Describe 'Set-AzDoAPICacheProject' {
    Mock List-DevOpsProjects {}
    Mock Get-DevOpsSecurityDescriptor {}
    Mock Add-CacheItem {}
    Mock Export-CacheObject {}

    BeforeAll {
        $Global:DSCAZDO_OrganizationName = "DefaultOrg"
        $projectsSample = @(
            @{ Name = "Project1"; Id = 1 },
            @{ Name = "Project2"; Id = 2 }
        )
        $securityDescriptorsSample = @(
            @{ ProjectId = 1; Descriptor = "Descriptor1" },
            @{ ProjectId = 2; Descriptor = "Descriptor2" }
        )
    }

    It 'Sets the project cache with provided organization name' {
        Mock List-DevOpsProjects { return $projectsSample }
        Mock Get-DevOpsSecurityDescriptor { param($ProjectId) $securityDescriptorsSample | Where-Object { $_.ProjectId -eq $ProjectId } }

        Set-AzDoAPICacheProject -OrganizationName "CustomOrg"
        Assert-MockCalled List-DevOpsProjects -Exactly 1 -Scope It -ParameterFilter { $Organization -eq "CustomOrg" }
        Assert-MockCalled Get-DevOpsSecurityDescriptor -Exactly $projectsSample.Count -Scope It
        Assert-MockCalled Add-CacheItem -Exactly $projectsSample.Count -Scope It
        Assert-MockCalled Export-CacheObject -Exactly 1 -Scope It
    }

    It 'Sets the project cache using global organization name when not provided' {
        Mock List-DevOpsProjects { return $projectsSample }
        Mock Get-DevOpsSecurityDescriptor { param($ProjectId) $securityDescriptorsSample | Where-Object { $_.ProjectId -eq $ProjectId } }

        Set-AzDoAPICacheProject
        Assert-MockCalled List-DevOpsProjects -Exactly 1 -Scope It -ParameterFilter { $Organization -eq $Global:DSCAZDO_OrganizationName }
        Assert-MockCalled Get-DevOpsSecurityDescriptor -Exactly $projectsSample.Count -Scope It
        Assert-MockCalled Add-CacheItem -Exactly $projectsSample.Count -Scope It
        Assert-MockCalled Export-CacheObject -Exactly 1 -Scope It
    }

    It 'Handles exceptions thrown during the process' {
        Mock List-DevOpsProjects { throw "Error retrieving projects" }

        { Set-AzDoAPICacheProject -OrganizationName "FailingOrg" } | Should -Throw "Error retrieving projects"
    }
}
