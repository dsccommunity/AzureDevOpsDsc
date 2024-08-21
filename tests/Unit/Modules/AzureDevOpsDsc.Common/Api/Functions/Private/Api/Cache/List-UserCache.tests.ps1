$currentFile = $MyInvocation.MyCommand.Path

Describe 'List-UserCache' {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'List-UserCache.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        Mock -CommandName Get-AzDevOpsApiVersion { return "5.0-preview.1" }
        Mock -CommandName Invoke-AzDevOpsApiRestMethod

    }

    Context 'when called with valid OrganizationName' {
        It 'should call Invoke-AzDevOpsApiRestMethod with correct parameters' {
            $OrganizationName = 'TestOrg'
            $ApiVersion = '5.0-preview.1'
            $response = @{
                value = @(
                    @{ displayName = 'User1' }
                    @{ displayName = 'User2' }
                )
            }

            Mock -CommandName Invoke-AzDevOpsApiRestMethod { return $response }

            $result = List-UserCache -OrganizationName $OrganizationName -ApiVersion $ApiVersion

            $expectedUri = "https://vssps.dev.azure.com/$OrganizationName/_apis/graph/users"
            Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Times 1 -Exactly -Scope It -ParameterFilter {
                $Uri -eq $expectedUri -and
                $Method -eq 'Get'
            }

            $result.Count | Should -Be 2
            $result[0].displayName | Should -Be 'User1'
            $result[1].displayName | Should -Be 'User2'
        }
    }

    Context 'when API returns null' {
        It 'should return null' {
            $OrganizationName = 'TestOrg'
            $ApiVersion = '5.0-preview.1'

            Mock -CommandName Invoke-AzDevOpsApiRestMethod { return @{ value = $null } }

            $result = List-UserCache -OrganizationName $OrganizationName -ApiVersion $ApiVersion

            $result | Should -BeNullOrEmpty
        }
    }

    Context 'when ApiVersion is not provided' {
        It 'should call Get-AzDevOpsApiVersion' {
            $OrganizationName = 'TestOrg'

            Mock -CommandName  Get-AzDevOpsApiVersion { return "5.0-preview.1" }

            $result = List-UserCache -OrganizationName $OrganizationName

            Assert-MockCalled -CommandName Get-AzDevOpsApiVersion -Exactly 1
        }
    }
}

