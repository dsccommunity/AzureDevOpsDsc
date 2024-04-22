<#
    .SYNOPSIS
        Tests for the 'Set-AzDevOpsProject' function to ensure it behaves as expected.

    .DESCRIPTION
        The tests will verify that the function correctly calls the necessary cmdlets with the appropriate parameters,
        and handles different scenarios such as valid and invalid inputs, and the use of the -Force parameter.
#>

Describe "Set-AzDevOpsProject Tests" {

    BeforeAll {
        # Mocking the dependent cmdlets used within the Set-AzDevOpsProject function
        Mock Test-AzDevOpsApiUri { return $true }
        Mock Test-AzDevOpsPat { return $true }
        Mock Test-AzDevOpsProjectId { return $true }
        Mock Test-AzDevOpsProjectName { return $true }
        Mock Test-AzDevOpsProjectDescription { return $true }
        Mock Set-AzDevOpsApiResource {}
        Mock Get-AzDevOpsProject { return @{ id = 'ValidProjectId'; name = 'UpdatedProjectName'; description = 'UpdatedProjectDescription' } }
    }

    It "Should call the dependent cmdlet 'Test-AzDevOpsApiUri' with the correct ApiUri" {
        Set-AzDevOpsProject -ApiUri 'https://dev.azure.com/validOrg/_apis/' -Pat 'ValidPAT' `
                            -ProjectId 'ValidProjectId' -ProjectName 'UpdatedProjectName' -ProjectDescription 'UpdatedProjectDescription'
        Assert-MockCalled Test-AzDevOpsApiUri -Exactly 1 -Scope It -ParameterFilter { $ApiUri -eq 'https://dev.azure.com/validOrg/_apis/' }
    }

    It "Should call the dependent cmdlet 'Test-AzDevOpsPat' with the correct PAT" {
        Set-AzDevOpsProject -ApiUri 'https://dev.azure.com/validOrg/_apis/' -Pat 'ValidPAT' `
                            -ProjectId 'ValidProjectId' -ProjectName 'UpdatedProjectName' -ProjectDescription 'UpdatedProjectDescription'
        Assert-MockCalled Test-AzDevOpsPat -Exactly 1 -Scope It -ParameterFilter { $Pat -eq 'ValidPAT' }
    }

    It "Should call the dependent cmdlet 'Test-AzDevOpsProjectId' with the correct ProjectId" {
        Set-AzDevOpsProject -ApiUri 'https://dev.azure.com/validOrg/_apis/' -Pat 'ValidPAT' `
                            -ProjectId 'ValidProjectId' -ProjectName 'UpdatedProjectName' -ProjectDescription 'UpdatedProjectDescription'
        Assert-MockCalled Test-AzDevOpsProjectId -Exactly 1 -Scope It -ParameterFilter { $ProjectId -eq 'ValidProjectId' }
    }

    It "Should call the dependent cmdlet 'Test-AzDevOpsProjectName' with the correct ProjectName" {
        Set-AzDevOpsProject -ApiUri 'https://dev.azure.com/validOrg/_apis/' -Pat 'ValidPAT' `
                            -ProjectId 'ValidProjectId' -ProjectName 'UpdatedProjectName' -ProjectDescription 'UpdatedProjectDescription'
        Assert-MockCalled Test-AzDevOpsProjectName -Exactly 1 -Scope It -ParameterFilter { $ProjectName -eq 'UpdatedProjectName' }
    }

    It "Should call 'Set-AzDevOpsApiResource' to update the project" {
        Set-AzDevOpsProject -ApiUri 'https://dev.azure.com/validOrg/_apis/' -Pat 'ValidPAT' `
                            -ProjectId 'ValidProjectId' -ProjectName 'UpdatedProjectName' -ProjectDescription 'UpdatedProjectDescription' -Force
        Assert-MockCalled Set-AzDevOpsApiResource -Exactly 1 -Scope It -ParameterFilter { $ResourceId -eq 'ValidProjectId' }
    }

    It "Should call 'Get-AzDevOpsProject' after updating the project" {
        Set-AzDevOpsProject -ApiUri 'https://dev.azure.com/validOrg/_apis/' -Pat 'ValidPAT' `
                            -ProjectId 'ValidProjectId' -ProjectName 'UpdatedProjectName' -ProjectDescription 'UpdatedProjectDescription' -Force
        Assert-MockCalled Get-AzDevOpsProject -Exactly 1 -Scope It -ParameterFilter { $ProjectId -eq 'ValidProjectId' }
    }

    It "Should pass the -Force parameter to 'Set-AzDevOpsApiResource' if specified" {
        Set-AzDevOpsProject -ApiUri 'https://dev.azure.com/validOrg/_apis/' -Pat 'ValidPAT' `
                            -ProjectId 'ValidProjectId' -ProjectName 'UpdatedProjectName' -ProjectDescription 'UpdatedProjectDescription' -Force
        Assert-MockCalled Set-AzDevOpsApiResource -Exactly 1 -Scope It -ParameterFilter { $Force }
    }

    It "Should throw an error if an invalid ApiUri is provided" {
        Mock Test-AzDevOpsApiUri { return $false }
        { Set-AzDevOpsProject -ApiUri 'InvalidApiUri' -Pat 'ValidPAT' `
                               -ProjectId 'ValidProjectId' -ProjectName 'UpdatedProjectName' -ProjectDescription 'UpdatedProjectDescription' } | Should -Throw
    }

    It "Should throw an error if an invalid PAT is provided" {
        Mock Test-AzDevOpsPat { return $false }
        { Set-AzDevOpsProject -ApiUri 'https://dev.azure.com/validOrg/_apis/' -Pat 'InvalidPAT' `
                               -ProjectId 'ValidProjectId' -ProjectName 'UpdatedProjectName' -ProjectDescription 'UpdatedProjectDescription' } | Should -Throw
    }

    It "Should throw an error if an invalid ProjectId is provided" {
        Mock Test-AzDevOpsProjectId { return $false }
        { Set-AzDevOpsProject -ApiUri 'https://dev.azure.com/validOrg/_apis/' -Pat 'ValidPAT' `
                               -ProjectId 'InvalidProjectId' -ProjectName 'UpdatedProjectName' -ProjectDescription 'UpdatedProjectDescription' } | Should -Throw
    }

    It "Should throw an error if an invalid ProjectName is provided" {
        Mock Test-AzDevOpsProjectName { return $false }
        { Set-AzDevOpsProject -ApiUri 'https://dev.azure.com/validOrg/_apis/' -Pat 'ValidPAT' `
                               -ProjectId 'ValidProjectId' -ProjectName 'InvalidProjectName' -ProjectDescription 'UpdatedProjectDescription' } | Should -Throw
    }
}
