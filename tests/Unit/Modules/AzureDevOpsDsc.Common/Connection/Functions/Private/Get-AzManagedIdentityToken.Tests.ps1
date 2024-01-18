# Initialize tests for module function
. $PSScriptRoot\..\..\..\..\AzureDevOpsDsc.Common.Tests.Initialization.ps1

InModuleScope 'AzureDevOpsDsc.Common' {

    Describe "Get-AzManagedIdentityToken Tests" {
        # Mock the dependent cmdlets and variables
        Mock Invoke-AzDevOpsApiRestMethod { return @{ access_token = "mocked_access_token" } }
        Mock Test-AzManagedIdentityToken { return $true }

        # Set up localized data variable which is used within the function
        $Global:AzManagedIdentityLocalizedData = @{
            Error_Azure_Get_AzManagedIdentity_Invalid_Caller = "Invalid Caller"
            Error_Azure_Instance_Metadata_Service_Missing_Token = "Missing Token"
            Error_Azure_API_Call_Generic = "API Call Failed"
            Global_Url_AzureInstanceMetadataUrl = "http://localhost/metadata/identity/oauth2/token"
            Global_AzureDevOps_Resource_Id = "resource_id"
        }

        # Define a test case where the function is called with mandatory parameters only
        It "Should return a token when called with mandatory parameters" {
            { Get-AzManagedIdentityToken -OrganizationName "Contoso" } | Should -Not -Throw
        }

        # Define a test case where the function is called from an invalid caller
        It "Should throw if called from an invalid caller" {
            Mock -CommandName 'New-AzManagedIdentity' -MockWith {}
            Mock -CommandName 'Update-AzManagedIdentity' -MockWith {}
            $scriptBlock = {
                Get-AzManagedIdentityToken -OrganizationName "Contoso"
            }
            $scriptBlock | Should -Throw $Global:AzManagedIdentityLocalizedData.Error_Azure_Get_AzManagedIdentity_Invalid_Caller
        }

        # Define a test case for verify switch
        It "Should verify the connection when the Verify switch is used" {
            Mock Test-AzManagedIdentityToken { return $true }
            { Get-AzManagedIdentityToken -OrganizationName "Contoso" -Verify } | Should -Not -Throw
        }

        # Define a test case for missing token in response
        It "Should throw if the access token is missing in the response" {
            Mock Invoke-AzDevOpsApiRestMethod { return @{} }
            { Get-AzManagedIdentityToken -OrganizationName "Contoso" } | Should -Throw $Global:AzManagedIdentityLocalizedData.Error_Azure_Instance_Metadata_Service_Missing_Token
        }

        # Define a test case for API call failure
        It "Should throw if the API call fails during verification" {
            Mock Test-AzManagedIdentityToken { return $false }
            { Get-AzManagedIdentityToken -OrganizationName "Contoso" -Verify } | Should -Throw $Global:AzManagedIdentityLocalizedData.Error_Azure_API_Call_Generic
        }
    }


}
