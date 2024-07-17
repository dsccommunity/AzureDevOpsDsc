powershell
Describe "List-DevOpsServicePrinciples" {
    Mock Get-AzDevOpsApiVersion {
        return "6.0-preview.1"
    }
    
    Mock Invoke-AzDevOpsApiRestMethod {
        return @{ value = @("serviceprincipal1", "serviceprincipal2") }
    }

    Context "When called with valid OrganizationName" {
        It "Should call Get-AzDevOpsApiVersion once" {
            List-DevOpsServicePrinciples -OrganizationName 'MyOrg'
            Assert-MockCalled Get-AzDevOpsApiVersion -Exactly 1
        }

        It "Should call Invoke-AzDevOpsApiRestMethod" {
            List-DevOpsServicePrinciples -OrganizationName 'MyOrg'
            Assert-MockCalled Invoke-AzDevOpsApiRestMethod -Exactly 1
        }

        It "Should return a list of service principals" {
            $result = List-DevOpsServicePrinciples -OrganizationName 'MyOrg'
            $result | Should -Be @("serviceprincipal1", "serviceprincipal2")
        }
    }

    Context "When no service principals are found" {
        Mock Invoke-AzDevOpsApiRestMethod {
            return @{ value = $null }
        }

        It "Should return $null" {
            $result = List-DevOpsServicePrinciples -OrganizationName 'MyOrg'
            $result | Should -Be $null
        }
    }

    Context "When called with specific ApiVersion" {
        It "Should use the provided ApiVersion" {
            Mock Invoke-AzDevOpsApiRestMethod -ParameterFilter {
                $Uri -eq "https://vssps.dev.azure.com/MyOrg/_apis/graph/serviceprincipals" -and
                $Method -eq "Get"
            } -MockWith {
                return @{ value = @("serviceprincipal3") }
            }

            $result = List-DevOpsServicePrinciples -OrganizationName 'MyOrg' -ApiVersion '5.0'
            $result | Should -Be @("serviceprincipal3")
        }
    }
}

