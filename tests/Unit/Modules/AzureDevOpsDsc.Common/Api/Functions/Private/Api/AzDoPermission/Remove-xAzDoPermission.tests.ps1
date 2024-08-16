
Describe 'Remove-xAzDoPermission' {
    Mock -CommandName Get-AzDevOpsApiVersion -MockWith { '5.1' }

    Context 'When invoked' {
        It 'Should call Invoke-AzDevOpsApiRestMethod with correct parameters' {
            # Arrange
            $OrganizationName = 'ExampleOrg'
            $SecurityNamespaceID = '00000000-0000-0000-0000-000000000000'
            $TokenName = 'ExampleToken'
            $ApiVersion = '5.1'

            Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
                return $true
            }

            # Act
            Remove-xAzDoPermission -OrganizationName $OrganizationName -SecurityNamespaceID $SecurityNamespaceID -TokenName $TokenName -ApiVersion $ApiVersion

            # Assert
            Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Exactly 1 -Scope It -ParameterFilter {
                $Uri -eq "https://dev.azure.com/$OrganizationName/_apis/accesscontrollists/$SecurityNamespaceID?tokens=$TokenName&recurse=False&api-version=$ApiVersion" -and
                $Method -eq 'DELETE'
            }
        }

        It 'Should handle exceptions and write error message' {
            # Arrange
            $OrganizationName = 'ExampleOrg'
            $SecurityNamespaceID = '00000000-0000-0000-0000-000000000000'
            $TokenName = 'ExampleToken'
            $ApiVersion = '5.1'

            Mock -CommandName Invoke-AzDevOpsApiRestMethod -MockWith {
                throw 'An error occurred'
            }

            # Act
            { Remove-xAzDoPermission -OrganizationName $OrganizationName -SecurityNamespaceID $SecurityNamespaceID -TokenName $TokenName -ApiVersion $ApiVersion } | Should -Throw

            # Assert
            Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Exactly 1 -Scope It
        }
    }
}

