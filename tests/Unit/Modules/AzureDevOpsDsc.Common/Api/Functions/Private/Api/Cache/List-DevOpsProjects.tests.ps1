powershell
Describe 'List-DevOpsProjects' {
    Mock Get-AzDevOpsApiVersion {
        return "6.0"
    }

    Mock Invoke-AzDevOpsApiRestMethod {
        return @{
            value = @(
                @{ id = '1'; name = 'ProjectOne' }, 
                @{ id = '2'; name = 'ProjectTwo' }
            )
        }
    }

    It 'Returns DevOps projects for a valid organization name' {
        $result = List-DevOpsProjects -OrganizationName 'TestOrg'

        $result | Should -Not -BeNullOrEmpty
        $result | Should -HaveCount 2
        $result[0].name | Should -Be 'ProjectOne'
        $result[1].name | Should -Be 'ProjectTwo'
    }

    It 'Returns null when no projects are found' {
        Mock Invoke-AzDevOpsApiRestMethod {
            return @{
                value = $null
            }
        }

        $result = List-DevOpsProjects -OrganizationName 'EmptyOrg'
        $result | Should -BeNull
    }

    It 'Calls Get-AzDevOpsApiVersion when ApiVersion is not supplied' {
        List-DevOpsProjects -OrganizationName 'TestOrg'
        Assert-MockCalled Get-AzDevOpsApiVersion -Exactly 1
    }

    It 'Uses the supplied ApiVersion when provided' {
        $apiVersion = '5.1'
        List-DevOpsProjects -OrganizationName 'TestOrg' -ApiVersion $apiVersion
        Assert-MockCalled Get-AzDevOpsApiVersion -Times 0
    }

    It 'Calls Invoke-AzDevOpsApiRestMethod with correct URI' {
        List-DevOpsProjects -OrganizationName 'TestOrg'
        Assert-MockCalled Invoke-AzDevOpsApiRestMethod -Exactly 1 -ParameterFilter {
            $params.Uri -eq "https://dev.azure.com/TestOrg/_apis/projects"
        }
    }
}

