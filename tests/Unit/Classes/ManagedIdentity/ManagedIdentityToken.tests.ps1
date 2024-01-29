# Initialize tests for module function

. $PSScriptRoot\..\Classes.TestInitialization.ps1

<#
.SYNOPSIS
    Test suite for the ManagedIdentityToken class.

.DESCRIPTION
    This test suite validates the functionality of the ManagedIdentityToken class, ensuring it handles various scenarios correctly.
#>

InModuleScope 'AzureDevOpsDsc' {

    Describe "ManagedIdentityToken Class Tests" {

        It "Throws an exception when invalid token object is provided" {
            { [ManagedIdentityToken]::new(@{}) } | Should -Throw "The ManagedIdentityTokenObj is not valid."
        }

        It "Creates a ManagedIdentityToken object with valid properties" {
            # Arrange
            $tokenProperties = @{
                access_token = "test_access_token"
                expires_on   = 3600 # Assuming this is seconds since epoch
                expires_in   = 3600
                resource     = "https://my.resource.com"
                token_type   = "Bearer"
            }
            # Act
            $tokenObject = [ManagedIdentityToken]::new((New-Object PSCustomObject -Property $tokenProperties))
            # Assert
            $tokenObject.access_token | Should -Not -BeNullOrEmpty
            $tokenObject.expires_on | Should -BeOfType [DateTime]
            $tokenObject.expires_in | Should -Be 3600
            $tokenObject.resource | Should -Be "https://my.resource.com"
            $tokenObject.token_type | Should -Be "Bearer"
        }

        It "Determines if a token is expired" {
            # Arrange
            $tokenProperties = @{
                access_token = "test_access_token"
                expires_on   = (Get-Date).AddSeconds(-20).ToUniversalTime().Subtract([datetime]::new(1970, 1, 1, 0, 0, 0, [DateTimeKind]::Utc)).TotalSeconds
                expires_in   = 3600
                resource     = "https://my.resource.com"
                token_type   = "Bearer"
            }
            $tokenObject = [ManagedIdentityToken]::new((New-Object PSCustomObject -Property $tokenProperties))
            # Act / Assert
            $tokenObject.isExpired() | Should -BeTrue
        }

        It "Gets the access token when called from an allowed method" {
            Mock Get-PSCallStack {
                return @(
                    @{Command="Invoke-AzDevOpsApiRestMethod"}
                )
            }
            # Arrange
            $tokenProperties = @{
                access_token = "test_access_token"
                expires_on   = 3600 # Assuming this is seconds since epoch
                expires_in   = 3600
                resource     = "https://my.resource.com"
                token_type   = "Bearer"
            }
            $tokenObject = [ManagedIdentityToken]::new((New-Object PSCustomObject -Property $tokenProperties))
            # Act
            $accessToken = $tokenObject.Get()
            # Assert
            $accessToken | Should -Be "test_access_token"
        }

        It "Throws an exception when Get method is called from a disallowed method" {
            Mock Get-PSCallStack {
                return @(
                    @{Command="Write-Host"}
                )
            }
            # Arrange
            $tokenProperties = @{
                access_token = "test_access_token"
                expires_on   = 3600 # Assuming this is seconds since epoch
                expires_in   = 3600
                resource     = "https://my.resource.com"
                token_type   = "Bearer"
            }
            $tokenObject = [ManagedIdentityToken]::new((New-Object PSCustomObject -Property $tokenProperties))
            # Act / Assert
            { $tokenObject.Get() } | Should -Throw "[ManagedIdentityToken] The Get() method can only be called within Invoke-AzDevOpsApiRestMethod."
        }
    }

}
