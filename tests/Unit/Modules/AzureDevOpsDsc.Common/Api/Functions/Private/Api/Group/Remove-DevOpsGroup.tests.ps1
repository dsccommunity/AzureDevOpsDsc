powershell
# Remove-DevOpsGroup.Tests.ps1

Import-Module Pester

Describe 'Remove-DevOpsGroup' {

    Mock Get-AzDevOpsApiVersion { return "6.0-preview.1" }
    Mock Invoke-AzDevOpsApiRestMethod { return @{ success = $true } }
        
    Context 'When called with mandatory parameters' {
        It 'should call the invoke method with correct parameters' {
            # Arrange
            $apiUri = "https://dev.azure.com/myorganization"
            $groupDescriptor = "MyGroup"
            $expectedUri = "$apiUri/_apis/graph/groups/$groupDescriptor?api-version=6.0-preview.1"
            $expectedMethod = 'Delete'

            # Act
            Remove-DevOpsGroup -ApiUri $apiUri -GroupDescriptor $groupDescriptor

            # Assert
            Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Exactly -Times 1 -Scope It -ParameterFilter {
                $PSBoundParameters['Uri'] -eq $expectedUri -and
                $PSBoundParameters['Method'] -eq $expectedMethod
            }
        }
    }

    Context 'When called without optional ApiVersion parameter' {
        It 'should call Get-AzDevOpsApiVersion to get default ApiVersion' {
            # Arrange
            $apiUri = "https://dev.azure.com/myorganization"
            $groupDescriptor = "MyGroup"

            # Act
            Remove-DevOpsGroup -ApiUri $apiUri -GroupDescriptor $groupDescriptor

            # Assert
            Assert-MockCalled -CommandName Get-AzDevOpsApiVersion -Exactly -Times 1
        }
    }

    Context 'When an error occurs during the API call' {
        It 'should write an error message' {
            # Arrange
            Mock Invoke-AzDevOpsApiRestMethod { 
                throw "API call failed"
            }
            $apiUri = "https://dev.azure.com/myorganization"
            $groupDescriptor = "MyGroup"
            $errorMessage = "Failed to remove group: API call failed"

            # Act
            $result = { Remove-DevOpsGroup -ApiUri $apiUri -GroupDescriptor $groupDescriptor } | Should -Throw

            # Assert
            $result.Message | Should -Contain $errorMessage
        }
    }

}

