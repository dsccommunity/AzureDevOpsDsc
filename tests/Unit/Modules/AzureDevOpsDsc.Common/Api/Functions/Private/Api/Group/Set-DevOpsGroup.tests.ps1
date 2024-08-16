
Describe 'Set-DevOpsGroup' {
    Mock -CommandName Get-AzDevOpsApiVersion -MockWith { return '6.0-preview.1' }
    Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith { return [PSCustomObject]@{displayName = 'MyGroup'; description = 'Updated group description'} }

    Context 'Default ParameterSet' {
        It 'Should invoke the API with correct parameters and update the group' {
            $params = @{
                ApiUri          = "https://dev.azure.com/contoso"
                GroupName       = "MyGroup"
                GroupDescription = "Updated group description"
                GroupDescriptor = "some-group-descriptor"
            }
            $result = Set-DevOpsGroup @params
            $result | Should -BeOfType [PSCustomObject]
            $result.displayName | Should -Be 'MyGroup'
            $result.description | Should -Be 'Updated group description'
            Assert-MockCalled Get-AzDevOpsApiVersion -Exactly 1
            Assert-MockCalled Invoke-AzDevOpsApiRestMethod -Exactly 1 -Scope It -ParameterFilter {
                $Uri -eq "https://dev.azure.com/contoso/_apis/graph/groups/some-group-descriptor?api-version=6.0-preview.1" -and
                $Method -eq 'Patch' -and
                $ContentType -eq 'application/json-patch+json'
            }
        }
    }

    Context 'ProjectScope ParameterSet' {
        It 'Should invoke the API with correct parameters and update the group within project scope' {
            $params = @{
                ApiUri               = "https://dev.azure.com/contoso"
                GroupName            = "MyGroup"
                GroupDescription     = "Updated group description"
                ProjectScopeDescriptor = "some-project-scope"
            }
            $result = Set-DevOpsGroup @params
            $result | Should -BeOfType [PSCustomObject]
            $result.displayName | Should -Be 'MyGroup'
            $result.description | Should -Be 'Updated group description'
            Assert-MockCalled Get-AzDevOpsApiVersion -Exactly 1
            Assert-MockCalled Invoke-AzDevOpsApiRestMethod -Exactly 1 -Scope It -ParameterFilter {
                $Uri -eq "https://dev.azure.com/contoso/_apis/graph/groups?scopeDescriptor=some-project-scope&api-version=6.0-preview.1" -and
                $Method -eq 'Patch' -and
                $ContentType -eq 'application/json-patch+json'
            }
        }
    }
}

