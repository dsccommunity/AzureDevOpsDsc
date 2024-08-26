$currentFile = $MyInvocation.MyCommand.Path

Describe "Set-AzPersonalAccessToken" -Tags "Unit", "Authentication" {

    BeforeAll {

        # Load the functions to test
        if ($null -eq $currentFile) {
            $currentFile = Join-Path -Path $PSScriptRoot -ChildPath 'Set-AzPersonalAccessToken.tests.ps1'
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

        Mock -CommandName New-PersonalAccessToken -MockWith { return }
        Mock -CommandName Test-AzToken -MockWith { return $true }

    }

    Context "with PersonalAccessToken parameter set" {
        It "should call New-PersonalAccessToken with the correct arguments" {
            $token = "testToken"
            $orgName = "testOrg"

            Set-AzPersonalAccessToken -OrganizationName $orgName -PersonalAccessToken $token

            Assert-MockCalled -CommandName New-PersonalAccessToken -Exactly 1 -ParameterFilter {
                $PersonalAccessToken -eq $token
            }
        }

        It "should return the token when Verify switch is not set" {
            $token = "testToken"
            Mock -CommandName New-PersonalAccessToken -MockWith { return $token }

            $result = Set-AzPersonalAccessToken -OrganizationName "testOrg" -PersonalAccessToken $token
            $result | Should -Be $token
        }

        It "should verify the connection when Verify switch is set" {
            $pattoken = "testToken"
            $orgName = "testOrg"

            Mock -CommandName Test-AzToken -MockWith { return $true }
            Mock -CommandName New-PersonalAccessToken -MockWith { return 'testToken' }

            $result = Set-AzPersonalAccessToken -OrganizationName $orgName -PersonalAccessToken $pattoken -Verify

            Assert-MockCalled -CommandName Test-AzToken -Exactly 1 -ParameterFilter {
                $pattoken -eq $token
            }
            $result | Should -Be $pattoken
        }
    }

    Context "with SecureStringPersonalAccessToken parameter set" {
        It "should call New-PersonalAccessToken with the correct arguments" {

            Mock -CommandName Test-AzToken -MockWith { return $true }
            Mock -CommandName New-PersonalAccessToken -MockWith {
                return (ConvertTo-SecureString -String "secureTestToken" -AsPlainText -Force)
            }

            $secureToken = ConvertTo-SecureString -String "secureTestToken" -AsPlainText -Force
            $orgName = "testOrg"

            $result = Set-AzPersonalAccessToken -OrganizationName $orgName -SecureStringPersonalAccessToken $secureToken
            Assert-MockCalled -CommandName New-PersonalAccessToken -Exactly 1 -ParameterFilter {
                $SecureStringPersonalAccessToken -ne $null
            }
            $result | Should -BeOfType [SecureString]

        }

        It "should verify the connection when Verify switch is set" {
            $secureToken = ConvertTo-SecureString -String "secureTestToken" -AsPlainText -Force
            $orgName = "testOrg"

            Mock -CommandName Test-AzToken -MockWith { return $true }
            Mock -CommandName New-PersonalAccessToken -MockWith {
                return (ConvertTo-SecureString -String "secureTestToken" -AsPlainText -Force)
            }

            $result = Set-AzPersonalAccessToken -OrganizationName $orgName -SecureStringPersonalAccessToken $secureToken -Verify

            Assert-MockCalled -CommandName New-PersonalAccessToken -Exactly 1 -ParameterFilter {
                $SecureStringPersonalAccessToken -ne $null
            }

            Assert-MockCalled -CommandName Test-AzToken -Exactly 1

            $result | Should -BeOfType [SecureString]
        }
    }

}
