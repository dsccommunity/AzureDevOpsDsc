# Save-Module `Pester` -Path 'path\to\somewhere'
Import-Module Pester

Describe 'New-AzDevOpsProject' {
    Mock -CommandName 'Test-AzDevOpsApiUri' -MockWith { $true }
    Mock -CommandName 'Test-AzDevOpsPat' -MockWith { $true }
    Mock -CommandName 'Test-AzDevOpsProjectName' -MockWith { $true }
    Mock -CommandName 'Test-AzDevOpsProjectDescription' -MockWith { $true }
    Mock -CommandName 'New-AzDevOpsProject' -MockWith { return @{ Name = $using:ProjectName } }

    $params = @{
        ApiUri             = 'https://dev.azure.com/someOrganizationName/_apis/'
        Pat                = 'fakePAT'
        ProjectName        = 'TestProject'
        ProjectDescription = 'Test Description'
        SourceControlType  = 'Git'
        Force              = $true
    }

    It 'Creates a new Azure DevOps Project' {
        $result = New-AzDevOpsProject @params
        $result.Name | Should -BeExactly ($params.ProjectName)
    }

    It 'Calls Test-AzDevOpsApiUri' {
        New-AzDevOpsProject @params
        Assert-MockCalled -CommandName 'Test-AzDevOpsApiUri' -Exactly -Times 1
    }

    It 'Calls Test-AzDevOpsPat' {
        New-AzDevOpsProject @params
        Assert-MockCalled -CommandName 'Test-AzDevOpsPat' -Exactly -Times 1
    }

    It 'Calls Test-AzDevOpsProjectName' {
        New-AzDevOpsProject @params
        Assert-MockCalled -CommandName 'Test-AzDevOpsProjectName' -Exactly -Times 1
    }

    It 'Calls Test-AzDevOpsProjectDescription' {
        New-AzDevOpsProject @params
        Assert-MockCalled -CommandName 'Test-AzDevOpsProjectDescription' -Exactly -Times 1
    }

    It 'Calls New-AzDevOpsProject with correct parameters' {
        New-AzDevOpsProject @params
        Assert-MockCalled -CommandName 'New-AzDevOpsProject' `
                          -Exactly -Times 1 `
                          -ParameterFilter { $ApiUri -eq $params.ApiUri -and $Pat -eq $params.Pat -and $Force -eq $params.Force }
    }
}
