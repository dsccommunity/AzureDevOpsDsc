
Describe 'List-DevOpsProcess' {
    Mock Get-AzDevOpsApiVersion { return "6.0" }
    Mock Invoke-AzDevOpsApiRestMethod {
        return @{
            value = @(
                @{ id = "1"; name = "Agile" }
                @{ id = "2"; name = "Scrum" }
            )
        }
    }

    Context 'When called with mandatory parameters' {
        It 'should return the process groups' {
            $result = List-DevOpsProcess -Organization "MyOrganization"
            $result | Should -Not -BeNullOrEmpty
            $result | Should -BeOfType 'System.Object[]'
            $result.Count | Should -Be 2
        }
    }

    Context 'When no processes are returned' {
        Mock Invoke-AzDevOpsApiRestMethod { return @{ value = $null } -MockScope It }

        It 'should return $null' {
            $result = List-DevOpsProcess -Organization "MyOrganization"
            $result | Should -Be $null
        }
    }

    Context 'When a specific API version is provided' {
        It 'should call Invoke-AzDevOpsApiRestMethod with the specified version' {
            $result = List-DevOpsProcess -Organization "MyOrganization" -ApiVersion "5.1"
            Assert-MockCalled Invoke-AzDevOpsApiRestMethod -Exactly 1 -Scope It -ParameterFilter {
                $params['Uri'] -eq 'https://dev.azure.com/MyOrganization/_apis/process/processes?api-version=5.1'
            }
        }
    }
}

