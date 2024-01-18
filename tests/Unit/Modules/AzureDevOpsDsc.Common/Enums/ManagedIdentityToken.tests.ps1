# Initialize tests for module function
. $PSScriptRoot\..\..\..\..\AzureDevOpsDsc.Common.Tests.Initialization.ps1


InModuleScope 'AzureDevOpsDsc.Common' {

    Describe "ManagedIdentityToken Class Tests" {
        Context "Constructor with Hashtable" {
            It "Initializes correctly with a valid hashtable" {
                $validHashTable = @{
                    access_token  = 'fake_access_token'
                    expires_on    = (Get-Date).AddHours(1).ToUniversalTime().Subtract([datetime]::new(1970, 1, 1, 0, 0, 0, [DateTimeKind]::Utc)).TotalSeconds
                    expires_in    = 3600
                    resource      = 'https://resource.url'
                    token_type    = 'Bearer'
                }

                { [ManagedIdentityToken]::new($validHashTable) } | Should -Not -Throw
                $managedIdentityToken = [ManagedIdentityToken]::new($validHashTable)
                ($managedIdentityToken.ConvertFromSecureString($managedIdentityToken.access_token)) | Should -Be 'fake_access_token'
                $managedIdentityToken.expires_in | Should -Be 3600
                $managedIdentityToken.resource | Should -Be 'https://resource.url'
                $managedIdentityToken.token_type | Should -Be 'Bearer'
            }

            It "Throws an error with an invalid hashtable" {
                $invalidHashTable = @{
                    access_token  = 'fake_access_token'
                    # Missing 'expires_on', 'expires_in', 'resource', and 'token_type'
                }

                { [ManagedIdentityToken]::new($invalidHashTable) } | Should -Throw "The ManagedIdentityTokenObj is not valid."
            }
        }

        Context "isValid Method" {
            It "Returns true for a valid hashtable" {
                $validHashTable = @{
                    access_token  = 'fake_access_token'
                    expires_on    = 1588342322
                    expires_in    = 3600
                    resource      = 'https://resource.url'
                    token_type    = 'Bearer'
                }
                $managedIdentityToken = [ManagedIdentityToken]::new($validHashTable)
                $result = $managedIdentityToken.isValid($validHashTable)
                $result | Should -Be $true
            }

            It "Returns false for an invalid hashtable" {
                $invalidHashTable = @{
                    access_token  = 'fake_access_token'
                    # Missing 'expires_on', 'expires_in', 'resource', and 'token_type'
                }
                $managedIdentityToken = [ManagedIdentityToken]::new($validHashTable)
                $result = $managedIdentityToken.isValid($invalidHashTable)
                $result | Should -Be $false
            }
        }

        Context "isExpired Method" {
            It "Returns false when token is not expired" {
                $validHashTable = @{
                    access_token  = 'fake_access_token'
                    expires_on    = (Get-Date).AddHours(1).ToUniversalTime().Subtract([datetime]::new(1970, 1, 1, 0, 0, 0, [DateTimeKind]::Utc)).TotalSeconds
                    expires_in    = 3600
                    resource      = 'https://resource.url'
                    token_type    = 'Bearer'
                }
                $managedIdentityToken = [ManagedIdentityToken]::new($validHashTable)
                $managedIdentityToken.isExpired() | Should -Be $false
            }

            It "Returns true when token is expired" {
                $validHashTable = @{
                    access_token  = 'fake_access_token'
                    expires_on    = (Get-Date).AddHours(-1).ToUniversalTime().Subtract([datetime]::new(1970, 1, 1, 0, 0, 0, [DateTimeKind]::Utc)).TotalSeconds
                    expires_in    = -3600
                    resource      = 'https://resource.url'
                    token_type    = 'Bearer'
                }
                $managedIdentityToken = [ManagedIdentityToken]::new($validHashTable)
                $managedIdentityToken.isExpired() | Should -Be $true
            }
        }

        Context "Get Method" {
            It "Throws an error when called outside of Invoke-AzDevOpsApiRestMethod" {
                Mock Get-PSCallStack { return @() }
                $validHashTable = @{
                    access_token  = 'fake_access_token'
                    expires_on    = 1588342322
                    expires_in    = 3600
                    resource      = 'https://resource.url'
                    token_type    = 'Bearer'
                }
                $managedIdentityToken = [ManagedIdentityToken]::new($validHashTable)
                { $managedIdentityToken.Get() } | Should -Throw "The Get() method can only be called within Invoke-AzDevOpsApiRestMethod."
            }

            # Additional tests would need to mock the call stack to simulate being within the allowed methods.
        }
    }

}
