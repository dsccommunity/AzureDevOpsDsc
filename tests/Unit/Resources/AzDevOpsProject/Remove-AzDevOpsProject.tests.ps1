<#
    .SYNOPSIS
        Tests for the 'Remove-AzDevOpsProject' function to ensure it behaves as expected.

    .DESCRIPTION
        The tests will verify that the function correctly calls the necessary cmdlets with the appropriate parameters,
        and handles different scenarios such as valid and invalid inputs, and the use of the -Force parameter.
#>

Describe "Remove-AzDevOpsProject Tests" {

    BeforeAll {
        # Mocking the dependent cmdlets used within the Remove-AzDevOpsProject function
        Mock Test-AzDevOpsApiUri { return $true }
        Mock Test-AzDevOpsPat { return $true }
        Mock Test-AzDevOpsProjectId { return $true }
        Mock Remove-AzDevOpsApiResource {}
    }

    It "Should call the dependent cmdlet 'Test-AzDevOpsApiUri' with the correct ApiUri" {
        Remove-AzDevOpsProject -ApiUri 'https://dev.azure.com/validOrg/_apis/' -Pat 'ValidPAT' -ProjectId 'ValidProjectId'
        Assert-MockCalled Test-AzDevOpsApiUri -Exactly 1 -Scope It -ParameterFilter { $ApiUri -eq 'https://dev.azure.com/validOrg/_apis/' }
    }

    It "Should call the dependent cmdlet 'Test-AzDevOpsPat' with the correct PAT" {
        Remove-AzDevOpsProject -ApiUri 'https://dev.azure.com/validOrg/_apis/' -Pat 'ValidPAT' -ProjectId 'ValidProjectId'
        Assert-MockCalled Test-AzDevOpsPat -Exactly 1 -Scope It -ParameterFilter { $Pat -eq 'ValidPAT' }
    }

    It "Should call the dependent cmdlet 'Test-AzDevOpsProjectId' with the correct ProjectId" {
        Remove-AzDevOpsProject -ApiUri 'https://dev.azure.com/validOrg/_apis/' -Pat 'ValidPAT' -ProjectId 'ValidProjectId'
        Assert-MockCalled Test-AzDevOpsProjectId -Exactly 1 -Scope It -ParameterFilter { $ProjectId -eq 'ValidProjectId' }
    }

    It "Should call 'Remove-AzDevOpsApiResource' to remove the project" {
        Remove-AzDevOpsProject -ApiUri 'https://dev.azure.com/validOrg/_apis/' -Pat 'ValidPAT' -ProjectId 'ValidProjectId' -Force
        Assert-MockCalled Remove-AzDevOpsApiResource -Exactly 1 -Scope It -ParameterFilter { $ResourceId -eq 'ValidProjectId' }
    }

    It "Should pass the -Force parameter to 'Remove-AzDevOpsApiResource' if specified" {
        Remove-AzDevOpsProject -ApiUri 'https://dev.azure.com/validOrg/_apis/' -Pat 'ValidPAT' -ProjectId 'ValidProjectId' -Force
        Assert-MockCalled Remove-AzDevOpsApiResource -Exactly 1 -Scope It -ParameterFilter { $Force }
    }

    It "Should throw an error if an invalid ApiUri is provided" {
        Mock Test-AzDevOpsApiUri { return $false }
        { Remove-AzDevOpsProject -ApiUri 'InvalidApiUri' -Pat 'ValidPAT' -ProjectId 'ValidProjectId' } | Should -Throw
    }

    It "Should throw an error if an invalid PAT is provided" {
        Mock Test-AzDevOpsPat { return $false }
        { Remove-AzDevOpsProject -ApiUri 'https://dev.azure.com/validOrg/_apis/' -Pat 'InvalidPAT' -ProjectId 'ValidProjectId' } | Should -Throw
    }

    It "Should throw an error if an invalid ProjectId is provided" {
        Mock Test-AzDevOpsProjectId { return $false }
        { Remove-AzDevOpsProject -ApiUri 'https://dev.azure.com/validOrg/_apis/' -Pat 'ValidPAT' -ProjectId 'InvalidProjectId' } | Should -Throw
    }
}
