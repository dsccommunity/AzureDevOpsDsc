# Initialize tests for module function
. $PSScriptRoot\..\..\..\..\AzureDevOpsDsc.Common.Tests.Initialization.ps1

InModuleScope 'AzureDevOpsDsc.Common' {

    Describe "Get-AzManagedIdentityToken" {

        Context 'When Azure instance metadata endpoint is defined' {

            It 'Should not throw an exception' {
                { Get-AzManagedIdentityToken } | Should -Not -Throw
            }

            It 'Should return a valid access token' {
                $accessToken = Get-AzManagedIdentityToken
                $accessToken | Should -Not -BeNullOrEmpty
            }

        }

    }
}
