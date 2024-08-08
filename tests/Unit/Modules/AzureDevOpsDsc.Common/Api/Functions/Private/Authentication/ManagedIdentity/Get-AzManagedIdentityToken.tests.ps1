Describe "Get-AzManagedIdentityToken Tests" {

    Mock -CommandName 'Invoke-AzDevOpsApiRestMethod' -MockWith {
        return @{
            access_token = "fake-access-token"
        }
    }

    Mock -CommandName 'New-ManagedIdentityToken' -MockWith {
        return @{
            AccessToken = "fake-access-token"
            Expiry = (Get-Date).AddHours(1)
        }
    }

    Mock -CommandName 'Test-AzToken' -MockWith {
        return $true
    }

    Context "When Verify switch is not set" {
        It "should return managed identity token" {
            $result = Get-AzManagedIdentityToken -OrganizationName "Contoso"
            $result.AccessToken | Should -Be "fake-access-token"
        }
    }

    Context "When Verify switch is set" {
        It "should return managed identity token after verification" {
            $result = Get-AzManagedIdentityToken -OrganizationName "Contoso" -Verify
            $result.AccessToken | Should -Be "fake-access-token"
        }

        It "should throw error if Token verification fails" {
            Mock -CommandName 'Test-AzToken' -MockWith { return $false }
            {
                Get-AzManagedIdentityToken -OrganizationName "Contoso" -Verify
            } | Should -Throw "Error. Failed to call the Azure DevOps API."
        }
    }

    Context "When access token is not returned from Azure Instance Metadata Service" {
        Mock -CommandName 'Invoke-AzDevOpsApiRestMethod' -MockWith {
            return @{
                access_token = $null
            }
        }

        It "should throw error" {
            {
                Get-AzManagedIdentityToken -OrganizationName "Contoso"
            } | Should -Throw "Error. Access token not returned from Azure Instance Metadata Service. Please ensure that the Azure Instance Metadata Service is available."
        }
    }

    Context "When there is an error in Invoke-AzDevOpsApiRestMethod" {
        Mock -CommandName 'Invoke-AzDevOpsApiRestMethod' -MockWith {
            throw "Rest API Failure"
        }

        It "should throw captured error" {
            {
                Get-AzManagedIdentityToken -OrganizationName "Contoso"
            } | Should -Throw "Rest API Failure"
        }
    }
}

