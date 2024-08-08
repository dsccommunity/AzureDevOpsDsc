Describe "List-DevOpsServicePrinciples" {
    Mock -CommandName Get-AzDevOpsApiVersion -MockWith { return "6.0-preview.1" }
    Mock -CommandName Invoke-AzDevOpsApiRestMethod

    Context "when OrganizationName is provided" {
        $orgName = "testOrg"
        $apiVersion = "6.0-preview.1"
        $mockServicePrincipalsResult = @{
            value = @(
                @{
                    id = "0001"
                    displayName = "ServicePrincipal1"
                },
                @{
                    id = "0002"
                    displayName = "ServicePrincipal2"
                }
            )
        }

        BeforeEach {
            Mock Invoke-AzDevOpsApiRestMethod -ParameterFilter {
                $PSCmdlet.MyInvocation.BoundParameters.Uri -eq "https://vssps.dev.azure.com/$orgName/_apis/graph/serviceprincipals"
            } -MockWith {
                return $mockServicePrincipalsResult
            }
        }

        It "Returns service principals if available" {
            $result = List-DevOpsServicePrinciples -OrganizationName $orgName -ApiVersion $apiVersion
            $result | Should -Not -BeNullOrEmpty
            $result | Should -HaveCount 2
            $result[0].displayName | Should -Be "ServicePrincipal1"
            $result[1].displayName | Should -Be "ServicePrincipal2"
        }

        It "Returns null if service principals result is null" {
            Mock Invoke-AzDevOpsApiRestMethod -MockWith { return @{ value = $null } }
            $result = List-DevOpsServicePrinciples -OrganizationName $orgName -ApiVersion $apiVersion
            $result | Should -BeNull
        }
    }

    Context "when OrganizationName is not provided" {
        It "Throws a validation error" {
            { List-DevOpsServicePrinciples -OrganizationName $null } | Should -Throw
        }
    }
}

