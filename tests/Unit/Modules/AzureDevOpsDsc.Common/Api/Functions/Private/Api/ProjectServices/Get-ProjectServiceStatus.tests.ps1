powershell
Describe 'Get-ProjectServiceStatus' {
    Mock Get-AzDevOpsApiVersion { return '5.0-preview.1' }
    Mock Invoke-AzDevOpsApiRestMethod

    Context 'When all parameters are provided' {
        It 'retrieves the project service status' {
            # Arrange
            $Organization = 'MyOrg'
            $ProjectId = '123456'
            $ServiceName = 'MyService'
            $ApiVersion = '6.0'
            $response = [PSCustomObject]@{ state = 'enabled' }

            Mock Invoke-AzDevOpsApiRestMethod { return $response }

            # Act
            $result = Get-ProjectServiceStatus -Organization $Organization -ProjectId $ProjectId -ServiceName $ServiceName -ApiVersion $ApiVersion

            # Assert
            $result | Should -Be $response
        }

        It 'defaults state to enabled if undefined' {
            # Arrange
            $Organization = 'MyOrg'
            $ProjectId = '123456'
            $ServiceName = 'MyService'
            $ApiVersion = '6.0'
            $response = [PSCustomObject]@{ state = 'undefined' }

            Mock Invoke-AzDevOpsApiRestMethod { return $response }

            # Act
            $result = Get-ProjectServiceStatus -Organization $Organization -ProjectId $ProjectId -ServiceName $ServiceName -ApiVersion $ApiVersion

            # Assert
            $result.state | Should -Be 'enabled'
        }
    }

    Context 'When ApiVersion is not provided' {
        It 'uses the default API version' {
            # Arrange
            $Organization = 'MyOrg'
            $ProjectId = '123456'
            $ServiceName = 'MyService'
            $response = [PSCustomObject]@{ state = 'enabled' }

            Mock Invoke-AzDevOpsApiRestMethod { return $response }

            # Act
            $result = Get-ProjectServiceStatus -Organization $Organization -ProjectId $ProjectId -ServiceName $ServiceName

            # Assert
            $result | Should -Be $response
            Assert-MockCalled Get-AzDevOpsApiVersion -Exactly 1
        }
    }

    Context 'When an exception occurs' {
        It 'writes an error message' {
            # Arrange
            $Organization = 'MyOrg'
            $ProjectId = '123456'
            $ServiceName = 'MyService'
            $ApiVersion = '6.0'

            Mock Invoke-AzDevOpsApiRestMethod { throw 'Error' }

            # Act
            { Get-ProjectServiceStatus -Organization $Organization -ProjectId $ProjectId -ServiceName $ServiceName -ApiVersion $ApiVersion } | Should -Throw

            # Assert
            Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Exactly 1
        }
    }
}

