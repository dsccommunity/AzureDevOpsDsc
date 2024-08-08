Describe 'Get-AzDevOpsApiResourceUri' {
    Mock Get-AzDevOpsApiVersion { return '6.0' }
    Mock Test-AzDevOpsApiUri { return $true }
    Mock Test-AzDevOpsApiVersion { return $true }
    Mock Test-AzDevOpsApiResourceName { return $true }
    Mock Test-AzDevOpsApiResourceId { return $true }
    Mock Get-AzDevOpsApiUriAreaName { param($ResourceName) return 'defaultarea' }
    Mock Get-AzDevOpsApiUriResourceName { param($ResourceName) return $ResourceName }

    Context 'When called with mandatory parameters only' {
        It 'Should return a valid URI with default API version' {
            $result = Get-AzDevOpsApiResourceUri -ApiUri 'https://dev.azure.com/someOrg/_apis/' -ResourceName 'Project'
            $expectedUri = 'https://dev.azure.com/someOrg/_apis/defaultarea/Project/?&api-version=6.0&includeCapabilities=true'
            $result | Should -Be $expectedUri
        }
    }

    Context 'When called with ResourceId' {
        It 'Should include the ResourceId in the returned URI' {
            $result = Get-AzDevOpsApiResourceUri -ApiUri 'https://dev.azure.com/someOrg/_apis/' -ResourceName 'Project' -ResourceId '12345'
            $expectedUri = 'https://dev.azure.com/someOrg/_apis/defaultarea/Project/12345/?&api-version=6.0&includeCapabilities=true'
            $result | Should -Be $expectedUri
        }
    }

    Context 'When called with custom ApiVersion' {
        It 'Should include the custom ApiVersion in the returned URI' {
            $result = Get-AzDevOpsApiResourceUri -ApiUri 'https://dev.azure.com/someOrg/_apis/' -ResourceName 'Project' -ApiVersion '5.0'
            $expectedUri = 'https://dev.azure.com/someOrg/_apis/defaultarea/Project/?&api-version=5.0&includeCapabilities=true'
            $result | Should -Be $expectedUri
        }
    }

    Context 'When ResourceName is in core area' {
        Mock Get-AzDevOpsApiUriAreaName { param($ResourceName) return 'core' }

        It 'Should not append area name to URI' {
            $result = Get-AzDevOpsApiResourceUri -ApiUri 'https://dev.azure.com/someOrg/_apis/' -ResourceName 'Project'
            $expectedUri = 'https://dev.azure.com/someOrg/_apis/Project/?&api-version=6.0&includeCapabilities=true'
            $result | Should -Be $expectedUri
        }
    }
}

