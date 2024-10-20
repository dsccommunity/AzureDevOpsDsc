$currentFile = $MyInvocation.MyCommand.Path

Describe 'List-DevOpsServicePrinciples' -Tags "Unit", "API" {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'List-DevOpsServicePrinciples.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        Mock -CommandName Get-AzDevOpsApiVersion {
            return '6.0-preview.1'
        }

        Mock -CommandName Invoke-AzDevOpsApiRestMethod {
            return @{
                value = @(
                    @{
                        id = 'sp1'
                        displayName = 'Service Principal 1'
                    },
                    @{
                        id = 'sp2'
                        displayName = 'Service Principal 2'
                    }
                )
            }
        }

    }

    Context 'When called with valid OrganizationName' {
        It 'Returns a list of service principals' {
            $result = List-DevOpsServicePrinciples -OrganizationName 'MyOrg'

            $result | Should -Not -BeNullOrEmpty
            $result | Should -HaveCount 2
            $result[0].id | Should -Be 'sp1'
            $result[0].displayName | Should -Be 'Service Principal 1'
            $result[1].id | Should -Be 'sp2'
            $result[1].displayName | Should -Be 'Service Principal 2'
        }

        It 'Uses the default API version if not provided' {
            List-DevOpsServicePrinciples -OrganizationName 'MyOrg'

            Assert-MockCalled Get-AzDevOpsApiVersion -Exactly 1 -Scope It
            Assert-MockCalled Invoke-AzDevOpsApiRestMethod -ParameterFilter {
                $Uri -eq 'https://vssps.dev.azure.com/MyOrg/_apis/graph/serviceprincipals' -and
                $Method -eq 'Get'
            } -Exactly 1 -Scope It
        }

        It 'Uses the provided API version if specified' {
            List-DevOpsServicePrinciples -OrganizationName 'MyOrg' -ApiVersion '5.0-preview.1'

            Assert-MockCalled Invoke-AzDevOpsApiRestMethod -ParameterFilter {
                $Uri -eq 'https://vssps.dev.azure.com/MyOrg/_apis/graph/serviceprincipals' -and
                $Method -eq 'Get'
            } -Exactly 1 -Scope It
        }
    }

    Context 'When API returns null' {

        It 'Returns null' {

            Mock -CommandName Invoke-AzDevOpsApiRestMethod {
                return @{ value = $null }
            }

            $result = List-DevOpsServicePrinciples -OrganizationName 'MyOrg'
            $result | Should -BeNull

        }
    }
}

