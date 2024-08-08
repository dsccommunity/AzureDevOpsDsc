Describe 'Remove-DevOpsProject' {

    Mock -CommandName Get-AzDevOpsApiVersion -MockWith { return '6.0' }
    Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith { return @{ status = '200' } }

    Context 'When called with valid parameters' {
        $params = @{
            Organization = 'TestOrg'
            ProjectId    = 'TestProj'
        }

        It 'Should call Get-AzDevOpsApiVersion' {
            Remove-DevOpsProject @params
            Assert-MockCalled -CommandName Get-AzDevOpsApiVersion -Times 1
        }

        It 'Should call Invoke-AzDevOpsApiRestMethod with the correct parameters' {
            Remove-DevOpsProject @params
            Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Times 1 -Exactly {
                Param(
                  [Hashtable]$params
                )
                $params.Uri -eq 'https://dev.azure.com/TestOrg/_apis/projects/TestProj?api-version=6.0' -and
                $params.Method -eq 'DELETE'
            }
        }

        It 'Should return the API response' {
            $result = Remove-DevOpsProject @params
            $result | Should -BeOfType [Hashtable]
            $result.status | Should -Be '200'
        }
    }

    Context 'When an error occurs during deletion' {
        Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith { throw 'Deletion failed' }

        It 'Should display an error message' {
            { Remove-DevOpsProject -Organization 'TestOrg' -ProjectId 'TestProj' } | Should -Throw
        }
    }
}

