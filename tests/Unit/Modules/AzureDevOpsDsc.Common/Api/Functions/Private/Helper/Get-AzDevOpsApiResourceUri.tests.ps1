
Describe 'Get-AzDevOpsApiResourceUri' {
    Mock Get-AzDevOpsApiVersion { return '6.0' }
    Mock Test-AzDevOpsApiUri { param($ApiUri) return $true }
    Mock Test-AzDevOpsApiVersion { param($ApiVersion) return $true }
    Mock Test-AzDevOpsApiResourceName { param($ResourceName) return $true }
    Mock Test-AzDevOpsApiResourceId { param($ResourceId) return $true }
    Mock Get-AzDevOpsApiUriAreaName { param($ResourceName) return 'core' }
    Mock Get-AzDevOpsApiUriResourceName { param($ResourceName) return $ResourceName }

    It 'Should return correct URI without ResourceId' {
        $uri = Get-AzDevOpsApiResourceUri -ApiUri 'https://dev.azure.com/someOrganizationName/_apis/' -ResourceName 'Project'
        $uri | Should -Be 'https://dev.azure.com/someOrganizationName/_apis/Project/?&api-version=6.0&includeCapabilities=true'
    }

    It 'Should return correct URI with ResourceId' {
        $uri = Get-AzDevOpsApiResourceUri -ApiUri 'https://dev.azure.com/someOrganizationName/_apis/' -ResourceName 'Project' -ResourceId '1234'
        $uri | Should -Be 'https://dev.azure.com/someOrganizationName/_apis/Project/1234/?&api-version=6.0&includeCapabilities=true'
    }

    It 'Should include api-version and includeCapabilities parameters' {
        $uri = Get-AzDevOpsApiResourceUri -ApiUri 'https://dev.azure.com/someOrganizationName/_apis/' -ResourceName 'Project'
        $uri | Should -Contain 'api-version=6.0'
        $uri | Should -Contain 'includeCapabilities=true'
    }

    It 'Should invoke dependent functions with correct parameters' {
        Get-AzDevOpsApiResourceUri -ApiUri 'https://dev.azure.com/someOrganizationName/_apis/' -ResourceName 'Project'
        Assert-MockCalled -ModuleName Get-AzDevOpsApiVersion -Exactly 1
        Assert-MockCalled -ModuleName Test-AzDevOpsApiUri -Exactly 1
        Assert-MockCalled -ModuleName Test-AzDevOpsApiVersion -Exactly 1
        Assert-MockCalled -ModuleName Test-AzDevOpsApiResourceName -Exactly 1
        Assert-MockCalled -ModuleName Test-AzDevOpsApiResourceId -Exactly 1
        Assert-MockCalled -ModuleName Get-AzDevOpsApiUriAreaName -Exactly 1
        Assert-MockCalled -ModuleName Get-AzDevOpsApiUriResourceName -Exactly 1
    }
}

