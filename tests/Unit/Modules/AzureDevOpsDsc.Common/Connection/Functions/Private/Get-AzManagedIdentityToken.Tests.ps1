<#
.SYNOPSIS
    Test suite for the Get-AzManagedIdentityToken function.

.DESCRIPTION
    This test suite validates the functionality of the Get-AzManagedIdentityToken function, ensuring it handles various scenarios correctly.
#>

. $PSScriptRoot\..\..\..\AzureDevOpsDsc.Common.TestInitialization.ps1

InModuleScope 'AzureDevOpsDsc.Common' {

    Describe "Get-AzManagedIdentityToken Function Tests" {

        BeforeAll {

            Import-Module 'AzureDevOpsDsc'

            Mock Invoke-AzDevOpsApiRestMethod {
                return @{
                    access_token = 'mock_access_token'
                    expires_on = 1000
                    expires_in = 1000
                    resource = "STRING"
                    token_type = "bearer"
                }
            }

            Mock Test-AzManagedIdentityToken {
                return $true
            }

        }

        It "Obtains a token without verifying if the Verify switch is not set" {
            # Arrange
            $organizationName = "Contoso"
            # Act
            $token = Get-AzManagedIdentityToken -OrganizationName $organizationName
            # Assert
            $token.access_token | Should -Be 'mock_access_token'
        }

        It "Verifies the connection and obtains a token when the Verify switch is set" {
            # Arrange
            $organizationName = "Contoso"
            # Act / Assert
            { Get-AzManagedIdentityToken -OrganizationName $organizationName -Verify } | Should -Not -Throw
        }

        It "Throws an exception if the Invoke-AzDevOpsApiRestMethod does not return an access token" {
            # Arrange
            Mock Invoke-AzDevOpsApiRestMethod {
                return @{}
            }
            $organizationName = "Contoso"
            # Act / Assert
            { Get-AzManagedIdentityToken -OrganizationName $organizationName } | Should -Throw "Error_Azure_Instance_Metadata_Service_Missing_Token"
        }

        It "Throws an exception if the Test-AzManagedIdentityToken returns false" {
            # Arrange
            Mock Test-AzManagedIdentityToken {
                return $false
            }
            $organizationName = "Contoso"
            # Act / Assert
            { Get-AzManagedIdentityToken -OrganizationName $organizationName -Verify } | Should -Throw "Error_Azure_API_Call_Generic"
        }
    }

}
