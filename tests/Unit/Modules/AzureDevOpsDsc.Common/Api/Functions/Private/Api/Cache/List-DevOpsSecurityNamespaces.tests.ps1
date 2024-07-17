powershell
# Unit Tests using Pester v5
Describe 'List-DevOpsSecurityNamespaces' {
    BeforeAll {
        # Mock the function Invoke-AzDevOpsApiRestMethod
        function Invoke-AzDevOpsApiRestMethod {
            param (
                $Uri,
                $Method
            )
            return @{ value = @( @{ id = 1; name = "Namespace1" }, @{ id = 2; name = "Namespace2" }) }
        }
    }

    It 'Should return namespaces for valid OrganizationName' {
        param (
            [string]$OrganizationName = 'ValidOrg'
        )

        $result = List-DevOpsSecurityNamespaces -OrganizationName $OrganizationName

        $result | Should -Not -BeNullOrEmpty
        $result | Should -HaveLength 2
        $result[0].name | Should -Be 'Namespace1'
    }

    It 'Should return null for invalid OrganizationName' {
        # Mock the function for invalid organization name
        Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
            return @{ value = $null }
        }

        $result = List-DevOpsSecurityNamespaces -OrganizationName 'InvalidOrg'

        $result | Should -BeNullOrEmpty
    }

    AfterAll {
        # Remove the mock
        Remove-Mock -CommandName Invoke-AzDevOpsApiRestMethod
    }
}

