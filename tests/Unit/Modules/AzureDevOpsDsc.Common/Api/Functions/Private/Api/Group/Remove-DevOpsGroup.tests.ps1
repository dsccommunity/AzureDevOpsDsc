powershell
Describe 'Remove-DevOpsGroup' {
    Mock Get-AzDevOpsApiVersion { "7.1-preview.1" }
    Mock Invoke-AzDevOpsApiRestMethod { 
        $null 
    }

    Context 'When all parameters are provided' {
        It 'Should call Invoke-AzDevOpsApiRestMethod with correct parameters' {
            $apiUri = "https://dev.azure.com/myorganization"
            $apiVersion = "7.1-preview.1"
            $groupDescriptor = "MyGroup"

            Remove-DevOpsGroup -ApiUri $apiUri -ApiVersion $apiVersion -GroupDescriptor $groupDescriptor

            Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Times 1 -Exactly -Scope It -Parameters @{
                Uri = "$apiUri/_apis/graph/groups/$groupDescriptor?api-version=$apiVersion"
                Method = 'Delete'
                ContentType = 'application/json'
            }
        }
        
        It 'Should use default ApiVersion if not provided' {
            $apiUri = "https://dev.azure.com/myorganization"
            $groupDescriptor = "MyGroup"

            Remove-DevOpsGroup -ApiUri $apiUri -GroupDescriptor $groupDescriptor

            Assert-MockCalled -CommandName Get-AzDevOpsApiVersion -Times 1 -Exactly -Scope It -Parameters @{
                Default = $true
            }
            Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Times 1 -Exactly -Scope It -Parameters @{
                Uri = "$apiUri/_apis/graph/groups/$groupDescriptor?api-version=7.1-preview.1"
                Method = 'Delete'
                ContentType = 'application/json'
            }
        }
    }
    
    Context 'Error Handling' {
        Mock Invoke-AzDevOpsApiRestMethod { throw 'API failure' }

        It 'Should handle errors and write an error message' {
            $apiUri = "https://dev.azure.com/myorganization"
            $groupDescriptor = "MyGroup"

            { Remove-DevOpsGroup -ApiUri $apiUri -GroupDescriptor $groupDescriptor } | Should -Throw

            Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Times 1 -Exactly -Scope It -Parameters @{
                Uri = "$apiUri/_apis/graph/groups/$groupDescriptor?api-version=7.1-preview.1"
                Method = 'Delete'
                ContentType = 'application/json'
            }
        }
    }
}

