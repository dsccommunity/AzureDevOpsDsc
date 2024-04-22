<#
    .SYNOPSIS
        Tests the 'Get-AzDevOpsProject' function to ensure it behaves as expected.

    .DESCRIPTION
        The tests cover various scenarios including valid and invalid inputs for parameters,
        ensuring that the correct projects are returned or appropriate errors are thrown.
#>

Describe "Get-AzDevOpsProject Tests" {

    BeforeAll {
        # Mocking the dependent cmdlets used within the Get-AzDevOpsProject function
        Mock Test-AzDevOpsApiUri { return $true }
        Mock Test-AzDevOpsPat { return $true }
        Mock Test-AzDevOpsProjectId { return $true }
        Mock Test-AzDevOpsProjectName { return $true }
        Mock Get-CacheItem { return @{ Value = "CachedProjectObject" } }

        # Assuming there's a function to add items to cache for testing
        Mock Set-CacheItem { return $null }
    }

    It "Should call the dependent cmdlet 'Test-AzDevOpsApiUri' with the correct ApiUri" {
        Get-AzDevOpsProject -ApiUri 'https://dev.azure.com/validOrg/_apis/' -Pat 'ValidPAT'
        Assert-MockCalled Test-AzDevOpsApiUri -Exactly 1 -Scope It -ParameterFilter { $ApiUri -eq 'https://dev.azure.com/validOrg/_apis/' }
    }

    It "Should call the dependent cmdlet 'Test-AzDevOpsPat' with the correct PAT" {
        Get-AzDevOpsProject -ApiUri 'https://dev.azure.com/validOrg/_apis/' -Pat 'ValidPAT'
        Assert-MockCalled Test-AzDevOpsPat -Exactly 1 -Scope It -ParameterFilter { $Pat -eq 'ValidPAT' }
    }

    It "Should call the dependent cmdlet 'Test-AzDevOpsProjectId' when ProjectId is provided" {
        Get-AzDevOpsProject -ApiUri 'https://dev.azure.com/validOrg/_apis/' -Pat 'ValidPAT' -ProjectId 'ValidProjectId'
        Assert-MockCalled Test-AzDevOpsProjectId -Exactly 1 -Scope It -ParameterFilter { $ProjectId -eq 'ValidProjectId' }
    }

    It "Should not call the dependent cmdlet 'Test-AzDevOpsProjectId' when ProjectId is not provided" {
        Get-AzDevOpsProject -ApiUri 'https://dev.azure.com/validOrg/_apis/' -Pat 'ValidPAT'
        Assert-MockCalled Test-AzDevOpsProjectId -Exactly 0 -Scope It
    }

    It "Should call the dependent cmdlet 'Test-AzDevOpsProjectName' when ProjectName is provided" {
        Get-AzDevOpsProject -ApiUri 'https://dev.azure.com/validOrg/_apis/' -Pat 'ValidPAT' -ProjectName 'ValidProjectName'
        Assert-MockCalled Test-AzDevOpsProjectName -Exactly 1 -Scope It -ParameterFilter { $ProjectName -eq 'ValidProjectName' }
    }

    It "Should not call the dependent cmdlet 'Test-AzDevOpsProjectName' when ProjectName is not provided" {
        Get-AzDevOpsProject -ApiUri 'https://dev.azure.com/validOrg/_apis/' -Pat 'ValidPAT'
        Assert-MockCalled Test-AzDevOpsProjectName -Exactly 0 -Scope It
    }

    It "Should return the cached project object when ProjectName is in the cache" {
        $result = Get-AzDevOpsProject -ApiUri 'https://dev.azure.com/validOrg/_apis/' -Pat 'ValidPAT' -ProjectName 'CachedProjectName'
        $result | Should -BeExactly "CachedProjectObject"
    }

    It "Should throw an error if an invalid ApiUri is provided" {
        Mock Test-AzDevOpsApiUri { return $false }
        { Get-AzDevOpsProject -ApiUri 'InvalidApiUri' -Pat 'ValidPAT' } | Should -Throw
    }

    It "Should throw an error if an invalid PAT is provided" {
        Mock Test-AzDevOpsPat { return $false }
        { Get-AzDevOpsProject -ApiUri 'https://dev.azure.com/validOrg/_apis/' -Pat 'InvalidPAT' } | Should -Throw
    }

    It "Should throw an error if an invalid ProjectId is provided" {
        Mock Test-AzDevOpsProjectId { return $false }
        { Get-AzDevOpsProject -ApiUri 'https://dev.azure.com/validOrg/_apis/' -Pat 'ValidPAT' -ProjectId 'InvalidProjectId' } | Should -Throw
    }

    It "Should throw an error if an invalid ProjectName is provided" {
        Mock Test-AzDevOpsProjectName { return $false }
        { Get-AzDevOpsProject -ApiUri 'https://dev.azure.com/validOrg/_apis/' -Pat 'ValidPAT' -ProjectName 'InvalidProjectName' } | Should -Throw
    }
}
