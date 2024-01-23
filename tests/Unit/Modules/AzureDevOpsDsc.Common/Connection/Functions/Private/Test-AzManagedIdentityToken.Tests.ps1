# Initialize tests for module function
. $PSScriptRoot\..\..\..\..\DSCClassResources.TestInitialization.ps1

<#
.SYNOPSIS
    Test suite for the Test-AzManagedIdentityToken function.

.DESCRIPTION
    This test suite validates the functionality of the Test-AzManagedIdentityToken function, ensuring it properly tests the managed identity token.
#>

Describe "Test-AzManagedIdentityToken Function Tests" {

    Mock Invoke-AzDevOpsApiRestMethod {
        return @{
            value = @("Project1", "Project2")
        }
    }

    BeforeAll {
        # Define a mock Managed Identity object with a Get method
        $mockManagedIdentity = New-Object -TypeName PSObject -Property @{
            Get = [ScriptBlock]::Create('return "mocked_access_token"')
        }

        # Set up a global variable as expected by the function
        $GLOBAL:DSCAZDO_OrganizationName = "MockOrganization"
    }

    It "Returns true when the managed identity token is valid" {
        # Arrange
        $AzManagedIdentityLocalizedData = @{
            Global_Url_AZDO_Project = "https://dev.azure.com/{0}/_apis/projects"
        }

        # Act
        $result = Test-AzManagedIdentityToken -ManagedIdentity $mockManagedIdentity

        # Assert
        $result | Should -Be $true
    }

    It "Returns false when the managed identity token is not valid" {
        # Arrange
        Mock Invoke-AzDevOpsApiRestMethod { throw "Unauthorized access." }
        $AzManagedIdentityLocalizedData = @{
            Global_Url_AZDO_Project = "https://dev.azure.com/{0}/_apis/projects"
        }

        # Act
        $result = Test-AzManagedIdentityToken -ManagedIdentity $mockManagedIdentity

        # Assert
        $result | Should -Be $false
    }
}
