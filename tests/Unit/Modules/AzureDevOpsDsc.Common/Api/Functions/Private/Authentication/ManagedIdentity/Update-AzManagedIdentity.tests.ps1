$currentFile = $MyInvocation.MyCommand.Path

Describe "Update-AzManagedIdentity" {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Get-AzManagedIdentityToken.tests.ps1'
        }

        # Load the functions to test
        $files = Invoke-BeforeEachFunctions (Find-Functions -TestFilePath $currentFile)
        ForEach ($file in $files) {
            . $file.FullName
        }

        # Import the enums
        Import-Enums | ForEach-Object {
            . $_.FullName
        }

        # Import the classes
        . (Get-ClassFilePath '001.AuthenticationToken')
        . (Get-ClassFilePath '002.PersonalAccessToken')
        . (Get-ClassFilePath '003.ManagedIdentityToken')


        Mock -CommandName Get-AzManagedIdentityToken -MockWith {}

    }

    Context "When the Global Organization Name is not set" {
        It "Throws an error" {
            $Global:DSCAZDO_OrganizationName = $null
            { Update-AzManagedIdentity } | Should -Throw '*Organization Name is not set*'
        }
    }

    Context "When the Global Organization Name is set" {
        BeforeEach {
            $Global:DSCAZDO_OrganizationName = "Contoso"
            $Global:DSCAZDO_AuthenticationToken = "oldToken"
        }

        It "Clears the existing token" {
            Update-AzManagedIdentity
            $Global:DSCAZDO_AuthenticationToken | Should -BeNullOrEmpty
        }

        It "Calls Get-AzManagedIdentityToken with the correct organization name" {
            Mock -CommandName Get-AzManagedIdentityToken -MockWith { return "newToken" }

            Update-AzManagedIdentity
            Assert-MockCalled -CommandName Get-AzManagedIdentityToken -Times 1 -Exactly -ParameterFilter { $OrganizationName -eq "Contoso" }
        }

        It "Sets the Global Authentication Token to the new token" {
            Mock -CommandName Get-AzManagedIdentityToken -MockWith { return "newToken" }

            Update-AzManagedIdentity
            $Global:DSCAZDO_AuthenticationToken | Should -Be "newToken"
        }
    }
}
