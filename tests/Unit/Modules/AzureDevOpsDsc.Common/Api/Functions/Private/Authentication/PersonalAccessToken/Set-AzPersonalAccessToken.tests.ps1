powershell
Describe "Set-AzPersonalAccessToken" {
    Mock New-PersonalAccessToken
    Mock Test-AzToken -MockWith { return $true }

    Context "with PersonalAccessToken parameter set" {
        It "should call New-PersonalAccessToken with the correct arguments" {
            $token = "testToken"
            $orgName = "testOrg"

            Set-AzPersonalAccessToken -OrganizationName $orgName -PersonalAccessToken $token

            Assert-MockCalled -CommandName New-PersonalAccessToken -Exactly 1 -Scope It -Parameters @{
                PersonalAccessToken = $token
            }
        }

        It "should return the token when Verify switch is not set" {
            $token = "testToken"
            Mock New-PersonalAccessToken -MockWith { return $token }

            $result = Set-AzPersonalAccessToken -OrganizationName "testOrg" -PersonalAccessToken $token

            $result | Should -Be $token
        }

        It "should verify the connection when Verify switch is set" {
            $token = "testToken"
            $orgName = "testOrg"
            Mock Test-AzToken -MockWith { return $true }

            $result = Set-AzPersonalAccessToken -OrganizationName $orgName -PersonalAccessToken $token -Verify

            Assert-MockCalled -CommandName Test-AzToken -Exactly 1 -Scope It -Parameters @{
                Token = $token
            }
            $result | Should -Be $token
        }
    }

    Context "with SecureStringPersonalAccessToken parameter set" {
        It "should call New-PersonalAccessToken with the correct arguments" {
            $secureToken = ConvertTo-SecureString -String "secureTestToken" -AsPlainText -Force
            $orgName = "testOrg"

            Set-AzPersonalAccessToken -OrganizationName $orgName -SecureStringPersonalAccessToken $secureToken

            Assert-MockCalled -CommandName New-PersonalAccessToken -Exactly 1 -Scope It -Parameters @{
                SecureStringPersonalAccessToken = $secureToken
            }
        }

        It "should return the token when Verify switch is not set" {
            $secureToken = ConvertTo-SecureString -String "secureTestToken" -AsPlainText -Force
            Mock New-PersonalAccessToken -MockWith { return "secureTestToken" }

            $result = Set-AzPersonalAccessToken -OrganizationName "testOrg" -SecureStringPersonalAccessToken $secureToken

            $result | Should -Be "secureTestToken"
        }

        It "should verify the connection when Verify switch is set" {
            $secureToken = ConvertTo-SecureString -String "secureTestToken" -AsPlainText -Force
            $orgName = "testOrg"
            Mock Test-AzToken -MockWith { return $true }

            $result = Set-AzPersonalAccessToken -OrganizationName $orgName -SecureStringPersonalAccessToken $secureToken -Verify

            Assert-MockCalled -CommandName Test-AzToken -Exactly 1 -Scope It -Parameters @{
                Token = "secureTestToken"
            }
            $result | Should -Be "secureTestToken"
        }
    }

    Context "when no token is provided" {
        It "should throw an error" {
            { Set-AzPersonalAccessToken -OrganizationName "testOrg" } | Should -Throw "Error. A Personal Access Token or SecureString Personal Access Token must be provided."
        }
    }
}

