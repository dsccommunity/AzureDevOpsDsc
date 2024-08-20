$currentFile = $MyInvocation.MyCommand.Path

Describe "List-DevOpsSecurityNamespaces" {

    BeforeAll {

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        Mock -CommandName Invoke-AzDevOpsApiRestMethod {
            return @{
                value = @(
                    @{
                        namespaceId = "testNamespace1"
                        description = "Test Namespace 1"
                    },
                    @{
                        namespaceId = "testNamespace2"
                        description = "Test Namespace 2"
                    }
                )
            }
        }

    }

    It "Should call Invoke-AzDevOpsApiRestMethod" {
        $organizationName = "TestOrganization"

        List-DevOpsSecurityNamespaces -OrganizationName $organizationName
        Assert-MockCalled Invoke-AzDevOpsApiRestMethod -ParameterFilter {
            $apiUri -eq "https://dev.azure.com/$organizationName/_apis/securitynamespaces/" -and
            $Method -eq 'Get'
        } -Times 1
    }

    It "Should return the namespaces value when present" {
        $organizationName = "TestOrganization"

        $result = List-DevOpsSecurityNamespaces -OrganizationName $organizationName
        $result | Should -HaveCount 2
        $result[0].namespaceId | Should -Be "testNamespace1"
        $result[1].namespaceId | Should -Be "testNamespace2"
    }

    It 'Should return $null when there are no namespaces' {
        Mock Invoke-AzDevOpsApiRestMethod {
            return @{
                value = $null
            }
        }

        $organizationName = "TestOrganization"

        $result = List-DevOpsSecurityNamespaces -OrganizationName $organizationName
        $result | Should -BeNullOrEmpty
    }
}

