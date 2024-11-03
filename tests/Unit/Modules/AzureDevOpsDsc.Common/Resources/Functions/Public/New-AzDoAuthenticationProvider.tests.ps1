$currentFile = $MyInvocation.MyCommand.Path

Describe "New-AzDoAuthenticationProvider" {

    AfterAll {
        Remove-Variable -Name DSCAZDO_OrganizationName -Scope Global
    }

    BeforeAll {

        # Set the Organization Name
        $Global:DSCAZDO_OrganizationName = 'TestOrganization'

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'New-AzDoAuthenticationProvider.tests.ps1'
        }

        # Load the functions to test
        $files = Get-FunctionItem (Find-MockedFunctions -TestFilePath $currentFile)

        ForEach ($file in $files) {
            . $file.FullName
        }

        # Mocking dependencies
        Mock -CommandName Set-AzPersonalAccessToken -MockWith { return "mockedToken" }
        Mock -CommandName Get-AzManagedIdentityToken -MockWith { return "mockedManagedIdentityToken" }
        Mock -CommandName Get-AzDoCacheObjects -MockWith { return @() }
        Mock -CommandName Get-Command
        Mock -CommandName Initialize-CacheObject
        Mock -CommandName Export-Clixml

    }

    BeforeEach {
        $ENV:AZDODSC_CACHE_DIRECTORY = "C:\MockCacheDirectory"
        $Global:DSCAZDO_AuthenticationToken = $null
    }

    AfterEach {
        $ENV:AZDODSC_CACHE_DIRECTORY = $null
        $Global:DSCAZDO_AuthenticationToken = $null
    }

    Context "When AZDODSC_CACHE_DIRECTORY is not set" {

        It "Should throw an error" {
            # Arrange
            $ENV:AZDODSC_CACHE_DIRECTORY = $null

            # Act & Assert
            {
                New-AzDoAuthenticationProvider -OrganizationName "Contoso" -PersonalAccessToken "dummyPat"
            } | Should -Throw "*The Environment Variable 'AZDODSC_CACHE_DIRECTORY' is not set*"
        }
    }

    Context "Using PersonalAccessToken parameter set" {
        It "Should set the global authentication token without verification" {
            # Act
            New-AzDoAuthenticationProvider -OrganizationName "Contoso" -PersonalAccessToken "dummyPat" -NoVerify

            # Assert
            $Global:DSCAZDO_AuthenticationToken | Should -Be "mockedToken"
            Assert-MockCalled -CommandName Set-AzPersonalAccessToken -Exactly 1
        }

        It "Should set the global authentication token with verification" {
            # Act
            New-AzDoAuthenticationProvider -OrganizationName "Contoso" -PersonalAccessToken "dummyPat"

            # Assert
            $Global:DSCAZDO_AuthenticationToken | Should -Be "mockedToken"
            Assert-MockCalled -CommandName Set-AzPersonalAccessToken -Exactly 1 -ParameterFilter { $Verify }
        }
    }

    Context "Using ManagedIdentity parameter set" {
        It "Should set the global authentication token without verification" {
            # Act
            New-AzDoAuthenticationProvider -OrganizationName "Contoso" -useManagedIdentity -NoVerify

            # Assert
            $Global:DSCAZDO_AuthenticationToken | Should -Be "mockedManagedIdentityToken"
            Assert-MockCalled -CommandName Get-AzManagedIdentityToken -Exactly 1
        }

        It "Should set the global authentication token with verification" {
            # Act
            New-AzDoAuthenticationProvider -OrganizationName "Contoso" -useManagedIdentity

            # Assert
            $Global:DSCAZDO_AuthenticationToken | Should -Be "mockedManagedIdentityToken"
            Assert-MockCalled -CommandName Get-AzManagedIdentityToken -Exactly 1 -ParameterFilter { $Verify }
        }
    }

    Context "Using SecureStringPersonalAccessToken parameter set" {
        It "Should set the global authentication token" {
            # Arrange
            $secureStringPAT = ConvertTo-SecureString "dummySecurePat" -AsPlainText -Force

            # Act
            New-AzDoAuthenticationProvider -OrganizationName "Contoso" -SecureStringPersonalAccessToken $secureStringPAT

            # Assert
            $Global:DSCAZDO_AuthenticationToken | Should -Be "mockedToken"
            Assert-MockCalled -CommandName Set-AzPersonalAccessToken -Exactly 1
        }
    }

    Context "Token export functionality" {
        It "Should export token information when isResource is not set" {
            # Act
            New-AzDoAuthenticationProvider -OrganizationName "Contoso" -PersonalAccessToken "dummyPat"

            # Assert
            Assert-MockCalled -CommandName Export-Clixml -Exactly 1
        }

        It "Should not export token information when isResource is set" {
            # Act
            New-AzDoAuthenticationProvider -OrganizationName "Contoso" -PersonalAccessToken "dummyPat" -isResource

            # Assert
            Assert-MockCalled -CommandName Export-Clixml -Exactly 0
        }
    }
}
