<#
    .SYNOPSIS
        Tests the 'New-AzDevOpsProject' function to ensure it behaves as expected.

    .DESCRIPTION
        The tests cover various scenarios including valid and invalid inputs for parameters,
        checking if the project is created with the correct settings, and ensuring that
        the function handles errors correctly.
#>

Describe "New-AzDevOpsProject Tests" {

    BeforeAll {
        # Mocking the dependent cmdlets used within the New-AzDevOpsProject function
        Mock Test-AzDevOpsApiUri { return $true }
        Mock Test-AzDevOpsPat { return $true }
        Mock Test-AzDevOpsProjectName { return $true }
        Mock Test-AzDevOpsProjectDescription { return $true }
        Mock New-AzDevOpsProject { return @{ Name = $ProjectName; Description = $ProjectDescription; SourceControlType = $SourceControlType } }
    }

    It "Should call the dependent cmdlet 'Test-AzDevOpsApiUri' with the correct ApiUri" {
        New-AzDevOpsProject -ApiUri 'https://dev.azure.com/validOrg/_apis/' -Pat 'ValidPAT' -ProjectName 'ValidProjectName'
        Assert-MockCalled Test-AzDevOpsApiUri -Exactly 1 -Scope It -ParameterFilter { $ApiUri -eq 'https://dev.azure.com/validOrg/_apis/' }
    }

    It "Should call the dependent cmdlet 'Test-AzDevOpsPat' with the correct PAT" {
        New-AzDevOpsProject -ApiUri 'https://dev.azure.com/validOrg/_apis/' -Pat 'ValidPAT' -ProjectName 'ValidProjectName'
        Assert-MockCalled Test-AzDevOpsPat -Exactly 1 -Scope It -ParameterFilter { $Pat -eq 'ValidPAT' }
    }

    It "Should call the dependent cmdlet 'Test-AzDevOpsProjectName' with the correct ProjectName" {
        New-AzDevOpsProject -ApiUri 'https://dev.azure.com/validOrg/_apis/' -Pat 'ValidPAT' -ProjectName 'ValidProjectName'
        Assert-MockCalled Test-AzDevOpsProjectName -Exactly 1 -Scope It -ParameterFilter { $ProjectName -eq 'ValidProjectName' }
    }

    It "Should call the dependent cmdlet 'Test-AzDevOpsProjectDescription' when a ProjectDescription is provided" {
        New-AzDevOpsProject -ApiUri 'https://dev.azure.com/validOrg/_apis/' -Pat 'ValidPAT' -ProjectName 'ValidProjectName' -ProjectDescription 'ValidProjectDescription'
        Assert-MockCalled Test-AzDevOpsProjectDescription -Exactly 1 -Scope It -ParameterFilter { $ProjectDescription -eq 'ValidProjectDescription' }
    }

    It "Should create a new project with default SourceControlType when not provided" {
        $result = New-AzDevOpsProject -ApiUri 'https://dev.azure.com/validOrg/_apis/' -Pat 'ValidPAT' -ProjectName 'ValidProjectName'
        $result.SourceControlType | Should -BeExactly 'Git'
    }

    It "Should create a new project with specified SourceControlType when provided" {
        $result = New-AzDevOpsProject -ApiUri 'https://dev.azure.com/validOrg/_apis/' -Pat 'ValidPAT' -ProjectName 'ValidProjectName' -SourceControlType 'Tfvc'
        $result.SourceControlType | Should -BeExactly 'Tfvc'
    }

    It "Should throw an error if an invalid ApiUri is provided" {
        Mock Test-AzDevOpsApiUri { return $false }
        { New-AzDevOpsProject -ApiUri 'InvalidApiUri' -Pat 'ValidPAT' -ProjectName 'ValidProjectName' } | Should -Throw
    }

    It "Should throw an error if an invalid PAT is provided" {
        Mock Test-AzDevOpsPat { return $false }
        { New-AzDevOpsProject -ApiUri 'https://dev.azure.com/validOrg/_apis/' -Pat 'InvalidPAT' -ProjectName 'ValidProjectName' } | Should -Throw
    }

    It "Should throw an error if an invalid ProjectName is provided" {
        Mock Test-AzDevOpsProjectName { return $false }
        { New-AzDevOpsProject -ApiUri 'https://dev.azure.com/validOrg/_apis/' -Pat 'ValidPAT' -ProjectName 'InvalidProjectName' } | Should -Throw
    }

    It "Should throw an error if an invalid ProjectDescription is provided" {
        Mock Test-AzDevOpsProjectDescription { return $false }
        { New-AzDevOpsProject -ApiUri 'https://dev.azure.com/validOrg/_apis/' -Pat 'ValidPAT' -ProjectName 'ValidProjectName' -ProjectDescription 'InvalidProjectDescription' } | Should -Throw
    }
}
