$currentFile = $MyInvocation.MyCommand.Path

Describe 'Remove-xAzDoPermission' {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Remove-xAzDoPermission.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        Mock -CommandName Get-AzDevOpsApiVersion -MockWith { '5.1' }

    }

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
            Mock -CommandName Write-Error

            # Act
            $result = Remove-xAzDoPermission -OrganizationName $OrganizationName -SecurityNamespaceID $SecurityNamespaceID -TokenName $TokenName -ApiVersion $ApiVersion

            # Assert
            $result | Should -BeNullOrEmpty
            Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Exactly 1 -ParameterFilter {
                $Uri -eq "https://dev.azure.com/$OrganizationName/_apis/securitynamespaces/$SecurityNamespaceID/descriptors/$TokenName?api-version=$ApiVersion"
                $Method -eq 'DELETE'
            }
            Assert-MockCalled -CommandName Write-Error -Exactly 0

        }

        It 'Should handle exceptions and write error message' {

            # Arrange
            $OrganizationName = 'ExampleOrg'
            $SecurityNamespaceID = '00000000-0000-0000-0000-000000000000'
            $TokenName = 'ExampleToken'
            $ApiVersion = '5.1'

            Mock -CommandName Invoke-AzDevOpsApiRestMethod
            Mock -CommandName Write-Error

            # Act
            $result = Remove-xAzDoPermission -OrganizationName $OrganizationName -SecurityNamespaceID $SecurityNamespaceID -TokenName $TokenName -ApiVersion $ApiVersion
            $result | Should -BeNullOrEmpty

            # Assert
            Assert-MockCalled -CommandName Write-Error -Exactly 1
            Assert-MockCalled -CommandName Invoke-AzDevOpsApiRestMethod -Exactly 1
        }
    }
}

