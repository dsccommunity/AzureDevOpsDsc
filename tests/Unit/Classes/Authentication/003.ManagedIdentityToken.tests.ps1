# Requires -Module Pester -Version 5.0.0

# Test if the class is defined
if ($Global:ClassesLoaded -eq $null)
{
    # Attempt to find the root of the repository
    $RepositoryRoot = (Get-Item -Path $PSScriptRoot).Parent.Parent.Parent.Parent.FullName
    # Load the classes
    $preInitialize = Get-ChildItem -Path "$RepositoryRoot" -Recurse -Filter '*.ps1' | Where-Object { $_.Name -eq 'Classes.BeforeAll.ps1' }
    . $preInitialize.FullName -RepositoryPath $RepositoryRoot
}


Describe 'ManagedIdentityToken Class' {
    Context 'Constructor with PSCustomObject Parameter' {

        BeforeAll {
            $epochStart = [datetime]::new(1970, 1, 1, 0, 0, 0, [DateTimeKind]::Utc)
        }

        It 'Should initialize with a valid ManagedIdentityTokenObj' {
            # Arrange

            $managedIdentityTokenObj = [PSCustomObject]@{
                access_token = "TestAccessToken"
                expires_on   = ($epochStart.AddMinutes(10) - [datetime]::UnixEpoch).TotalSeconds
                expires_in   = 600
                resource     = "https://resource.url"
                token_type   = "Bearer"
            }

            # Act
            $mit = [ManagedIdentityToken]::new($managedIdentityTokenObj)

            # Assert
            $mit.tokenType | Should -Be 'ManagedIdentity'
            $mit.ConvertFromSecureString($mit.access_token) | Should -Be "TestAccessToken"
            $mit.expires_on | Should -Be $epochStart.AddMinutes(10)
            $mit.expires_in | Should -Be 600
            $mit.resource | Should -Be "https://resource.url"
            $mit.token_type | Should -Be "Bearer"
        }

        It 'Should throw an error with an invalid ManagedIdentityTokenObj' {
            # Arrange
            $invalidManagedIdentityTokenObj = [PSCustomObject]@{
                access_token = "TestAccessToken"
                expires_on   = ($epochStart.AddMinutes(10) - [datetime]::UnixEpoch).TotalSeconds
                expires_in   = 600
                resource     = "https://resource.url"
                # Missing token_type
            }

            # Act & Assert
            { [ManagedIdentityToken]::new($invalidManagedIdentityTokenObj) } | Should -Throw '*The ManagedIdentityTokenObj is not valid*'
        }
    }

    Context 'isExpired Method' {
        It 'Should return true if the token is expired' {
            # Arrange
            $expiredTokenObj = [PSCustomObject]@{
                access_token = "TestAccessToken"
                expires_on   = ($epochStart.AddMinutes(-10) - [datetime]::UnixEpoch).TotalSeconds
                expires_in   = -600
                resource     = "https://resource.url"
                token_type   = "Bearer"
            }
            $mit = [ManagedIdentityToken]::new($expiredTokenObj)

            # Act
            $result = $mit.isExpired()

            # Assert
            $result | Should -Be $true
        }

        It 'Should return false if the token is not expired' {
            # Arrange
            $validTokenObj = [PSCustomObject]@{
                access_token = "TestAccessToken"
                expires_on   = 1820701735
                expires_in   = 600
                resource     = "https://resource.url"
                token_type   = "Bearer"
            }
            $mit = [ManagedIdentityToken]::new($validTokenObj)

            # Act
            $result = $mit.isExpired()

            # Assert
            $result | Should -Be $false
        }
    }

}

Describe 'New-ManagedIdentityToken Function' {
    It 'Should create a new ManagedIdentityToken object with a valid PSCustomObject' {
        # Arrange
        $epochStart = [datetime]::new(1970, 1, 1, 0, 0, 0, [DateTimeKind]::Utc)
        $managedIdentityTokenObj = [PSCustomObject]@{
            access_token = "TestAccessToken"
            expires_on   = ($epochStart.AddMinutes(10) - [datetime]::UnixEpoch).TotalSeconds
            expires_in   = 600
            resource     = "https://resource.url"
            token_type   = "Bearer"
        }

        # Act
        $mit = New-ManagedIdentityToken -ManagedIdentityTokenObj $managedIdentityTokenObj

        # Assert
        $mit | Should -BeOfType [ManagedIdentityToken]
        $mit.ConvertFromSecureString($mit.access_token) | Should -Be "TestAccessToken"
        $mit.expires_on | Should -Be $epochStart.AddMinutes(10)
        $mit.expires_in | Should -Be 600
        $mit.resource | Should -Be "https://resource.url"
        $mit.token_type | Should -Be "Bearer"
    }

    It 'Should throw an error if the ManagedIdentityTokenObj is invalid' {
        # Arrange
        $invalidManagedIdentityTokenObj = [PSCustomObject]@{
            access_token = "TestAccessToken"
            expires_on   = ($epochStart.AddMinutes(10) - [datetime]::UnixEpoch).TotalSeconds
            expires_in   = 600
            resource     = "https://resource.url"
            # Missing token_type
        }

        # Act & Assert
        { New-ManagedIdentityToken -ManagedIdentityTokenObj $invalidManagedIdentityTokenObj } | Should -Throw "*The ManagedIdentityTokenObj is not valid*"
    }
}
