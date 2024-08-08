Describe "List-DevOpsSecurityNamespaces" {
    Mock -ModuleName ModuleName -FunctionName Invoke-AzDevOpsApiRestMethod {
        return @{
            value = @(
                @{ id = 'namespace1'; name = 'Namespace 1' },
                @{ id = 'namespace2'; name = 'Namespace 2' }
            )
        }
    }

    Context "With valid OrganizationName" {
        It "Returns the security namespaces" {
            $result = List-DevOpsSecurityNamespaces -OrganizationName 'testOrg'
            $result | Should -Not -BeNullOrEmpty
            $result | Should -HaveCount 2
            $result[0].name | Should -Be 'Namespace 1'
            $result[1].name | Should -Be 'Namespace 2'
        }
    }

    Context "With no OrganizationName" {
        It "Throws a parameter binding exception" {
            { List-DevOpsSecurityNamespaces } | Should -Throw -ErrorId 'ParameterBindingValidationException'
        }
    }

    Context "With no namespaces returned" {
        Mock -ModuleName ModuleName -FunctionName Invoke-AzDevOpsApiRestMethod {
            return @{ value = @() }
        }

        It "Returns $null" {
            $result = List-DevOpsSecurityNamespaces -OrganizationName 'testOrg'
            $result | Should -BeNull
        }
    }
}

