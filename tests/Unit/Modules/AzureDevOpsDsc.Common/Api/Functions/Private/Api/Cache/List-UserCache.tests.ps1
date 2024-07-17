powershell
Describe 'List-UserCache' {
    Param (
        [string]$OrganizationName = 'dummyOrg',
        [string]$ApiVersion = '6.0-preview.1'
    )

    Mock -CommandName Get-AzDevOpsApiVersion -MockWith { return '6.0-preview.1' }
    Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
        return @{
            value = @(
                @{id = 1; displayName = 'User One'},
                @{id = 2; displayName = 'User Two'}
            )
        }
    }

    Context 'When mandatory parameter is missing' {
        It 'Should throw an error if OrganizationName is not provided' {
            { List-UserCache } | Should -Throw
        }
    }

    Context 'When OrganizationName is provided' {
        It 'Should call Get-AzDevOpsApiVersion if ApiVersion is not provided' {
            List-UserCache -OrganizationName $OrganizationName
            Assert-MockCalled Get-AzDevOpsApiVersion -Exactly -Times 1
        }

        It 'Should not call Get-AzDevOpsApiVersion if ApiVersion is provided' {
            List-UserCache -OrganizationName $OrganizationName -ApiVersion $ApiVersion
            Assert-MockCalled Get-AzDevOpsApiVersion -Exactly -Times 0
        }

        It 'Should call Invoke-AzDevOpsApiRestMethod with correct parameters' {
            List-UserCache -OrganizationName $OrganizationName -ApiVersion $ApiVersion
            Assert-MockCalled Invoke-AzDevOpsApiRestMethod -Exactly -Times 1 -Scope Context -ParameterFilter {
                $params.Uri -eq "https://vssps.dev.azure.com/$OrganizationName/_apis/graph/users" -and
                $params.Method -eq 'Get'
            }
        }

        It 'Should return the users if response contains value' {
            $result = List-UserCache -OrganizationName $OrganizationName -ApiVersion $ApiVersion
            $result | Should -Not -BeNullOrEmpty
            $result | Should -BeOfType 'System.Object[]'
            $result.Count | Should -Be 2
        }

        It 'Should return $null if there are no users' {
            Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith { return @{} }
            $result = List-UserCache -OrganizationName $OrganizationName -ApiVersion $ApiVersion
            $result | Should -BeNull
        }
    }
}

